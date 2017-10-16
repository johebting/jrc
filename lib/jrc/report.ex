defmodule Jrc.Report do

  @content_type [ "Content-Type": "application/json" ]
  @accept       [ "accept": "*/*" ]
  @base_header  @content_type ++ @accept

  def fetch(path, username, password, project) do
    report_url(path, username, project)
    |> HTTPoison.get(header(username, password))
    |> handle_response
    |> prettify(username)
  end

  def report_url(path, username, project \\ :all_project)
  def report_url(path, username, :all_project) do
    "https://#{path}/rest/api/2/search?maxResults=10000&fields=worklog,timetracking&jql=worklogAuthor%3D#{username}"
  end
  def report_url(path, username, project) do 
    report_url(path, username, :all_project) <> "%20AND%20project%3D#{project}"
  end

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({ _, %{status_code: _, body: body}}) do
    { :error, Poison.Parser.parse!(body) }
  end

  def get_auth(username, password) do
    Base.encode64("#{username}:#{password}")
  end

  def header(username, password) do
    auth = get_auth(username, password)
    @base_header ++ ["Authorization": "Basic #{auth}"]
  end

  def prettify({:ok, content}, username) do

    Enum.reduce(content["issues"], 0, fn(issue, totalTime) ->
      issue
      |> Map.get("fields")
      |> Map.get("worklog")
      |> Map.get("worklogs")
      |> Enum.reduce(0, fn(worklog, issueTime) ->
        if worklog["author"]["key"] == username do
          issueTime + worklog["timeSpentSeconds"] 
        else
          issueTime
        end
      end)
      |> Kernel.div(3600)
      |> Kernel.+(totalTime)
    end)
    |> Kernel.div(8)
    |> Integer.to_string
    |> Kernel.<>("d")

  end
  def preffify({:error, content}) do
    {_, message} = List.keyfind(content, "message", 0)
    IO.inspect "Error fetching from jira: #{message}"
    System.halt(2)
  end

end