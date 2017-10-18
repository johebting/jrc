defmodule Jrc.Report do
  @moduledoc """
  Format request for JIRA API, and fetch response
  """

  @content_type ["Content-Type": "application/json"]
  @accept       ["accept": "*/*"]
  @base_header  @content_type ++ @accept

  def fetch(path, username, password, project, days_count) do
    limit_date = get_limit_date(days_count)
    report_url = report_url(path, username, limit_date, project)
    
    report_url
      |> HTTPoison.get(header(username, password))
      |> handle_response
      |> prettify(username)
  end

  def get_limit_date(days_count) do
    Date.utc_today |> Date.add(-days_count) |> Date.to_string
  end

  def report_url(path, username),
    do: "https://#{path}/rest/api/2/search?maxResults=10000&fields=worklog,timetracking&jql=worklogAuthor%3D#{username}"
  def report_url(path, username, limit_date),
    do: report_url(path, username) <> "%20AND%20Updated%20>%3D%20#{limit_date}"
  def report_url(path, username, limit_date, project) do
    if project != :all_project do
      report_url(path, username, limit_date, :all_project) <> "%20AND%20project%3D#{project}"
    else
      report_url(path, username, limit_date)
    end
  end

  def handle_response({:ok, %{status_code: 200, body: body}}),
    do: {:ok, Poison.Parser.parse!(body)}
  def handle_response({_, %{status_code: _, body: body}}),
    do: {:error, Poison.Parser.parse!(body)}

  def get_auth(username, password), do: Base.encode64("#{username}:#{password}")

  def header(username, password) do
    auth = get_auth(username, password)
    @base_header ++ ["Authorization": "Basic #{auth}"]
  end

  def prettify({:ok, content}, username), 
    do: content |> Map.get("issues", %{}) |> Jrc.Formatter.format_report(username) |> Jrc.Tableizer.tableize
  def preffify({:error, content}) do
    {_, message} = List.keyfind(content, "message", 0)
    IO.puts "Error fetching from jira: #{message}"
    System.halt(2)
  end
end
