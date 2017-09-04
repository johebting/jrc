defmodule Jrc.Report do

  @content_type [ "Content-Type": "application/json" ]
  @accept       [ "accept": "*/*" ]
  @base_header  @content_type ++ @accept

  def fetch(path, username, password) do
    report_url(path)
    |> HTTPoison.get(header(username, password))
    |> handle_response
    |> preffify
  end

  def report_url(path) do
    "https://#{path}/rest/api/2/search"
  end

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({ _, %{status_code: _, body: body}}) do
    IO.inspect body
    { :error, Poison.Parser.parse!(body) }
  end

  def get_auth(username, password) do
    Base.encode64("#{username}:#{password}")
  end

  def header(username, password) do
    auth = get_auth(username, password)
    @base_header ++ ["Authorization": "Basic #{auth}"]
  end

  def prettify({:ok, content}), do: content
  def preffify({:error, content}) do
    {_, message} = List.keyfind(content, "message", 0)
    IO.puts "Error fetching from jira: #{message}"
    System.halt(2)
  end

end