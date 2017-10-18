defmodule Jrc.CLI do
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up genearting a
  summary of your Jira inputs.
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a Jira path (URL), username, password, project, and (optionally)
  the number of days to get or the project.
  Return a tuple of `{ path, username, password, days_count, project }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    
    case parse do
      {[help: true], _, _}
        -> :help

      {a, _, _} ->
        path = a[:path] || Application.get_env(:jrc, :jira_path)
        username = a[:username] || Application.get_env(:jrc, :username)
        password = a[:password] || Application.get_env(:jrc, :password)
        project = a[:project] || Application.get_env(:jrc, :default_project)
        brut_days_count = a[:days] || Application.get_env(:jrc, :default_days_count)
        days_count =
          if String.valid?(brut_days_count) do
            String.to_integer(brut_days_count)
          else
            brut_days_count
          end
        
        {path, username, password, project, days_count}
    end
  end

  def process(:help) do
    IO.puts """
    usage: jrc [--path] [--username] [--password] [--project] [--days] [--help]

      --path      Path to JIRA. For example: jira.domain.com
      --username  Username of your JIRA account.
      --password  Password of you JIRA account.
      --project   Project's name to filter on. By default :all_project are used.
      --days      Number of days in past to fetch. (currently not working)

    You can also set those parameters in the config.exs file located in the config/ folder.
    """
    System.halt(0)
  end

  def process({path, username, password, project, days_count}) do
    Jrc.Report.fetch(path, username, password, project, days_count)
  end

end