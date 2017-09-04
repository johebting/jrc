defmodule Jrc.CLI do

  @default_days_count 7
  @default_project :all_project

  @module_doc """
  Handle the command line parsing and the dispatch to
  the various functions that end up genearting a
  summary of your Jira inputs.
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
    |> IO.inspect
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a Jira path (URL), username, password, project, and (optionally)
  the number of days to get or the project.
  Return a tuple of `{ path, username, password, days_count, project }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])

    IO.inspect(parse)
    
    case parse do
      { [ help: true ], _, _ }
        -> :help

      { _, [ path, username, password, days_count, project ], _ }
        -> { path, username, password, String.to_integer(days_count), project }

      { _, [ path, username, password, days_count ], _ }
        -> { path, username, password, String.to_integer(days_count), @default_project }

      { _, [ path, username, password ], _ }
        -> { path, username, password, @default_days_count, @default_project }

      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: <path> <username> <password> [ days_count | #{@default_days_count} ] [ project | #{@default_project} ]
    """
    System.halt(0)
  end

  def process({path, username, password, _days_count, _project}) do
    Jrc.Report.fetch(path, username, password)
  end

end