defmodule Jrc.Formatter do
  @module_doc """
  Format the JIRA API response, as a Map with date as keys, and Maps as values.
  Those sub-Maps contains time spent per issue (in hours).
  """

  @doc """
  Format Enum of issues for the given user, as specified in the @module_doc
  """
  def format_report(issues, user) do
    issues
    |> Enum.reduce(%{}, fn(issue, tree) ->
      issue_key = Map.get(issue, "key")

      issue
      |> get_user_worklogs(user)
      |> Enum.reduce(tree, fn(worklog, pop_tree) -> 
        worklog_date = get_worklog_date(worklog)
        hours_spent = get_hours_spent(worklog)

        pop_tree
        |> Map.put_new(worklog_date, %{})
        |> Map.update!(worklog_date, fn(date_row) ->
          date_row
          |> Map.put_new(issue_key, 0)
          |> Map.update!(issue_key, &(&1 + hours_spent))
        end)
      end)
    end)
  end
  
  @doc """
  Get a Map full of user's worklogs of an issue
  """
  def get_user_worklogs(issue, user) do
    issue |> get_issue_worklogs |> Enum.filter(&(&1["author"]["key"] == user))
  end

  @doc """
  Get a Map full of all worklogs of an issue
  """
  def get_issue_worklogs(issue) do
    issue |> Map.get("fields") |> Map.get("worklog") |> Map.get("worklogs")
  end

  @doc """
  Divide number of seconds spent in a worklog to get it as hours
  """
  def get_hours_spent(worklog) do
    worklog |> Map.get("timeSpentSeconds") |> Kernel.div(3600) |> round
  end

  @doc """
  Get YYYY-mm-dd formatted date of a worklog
  """
  def get_worklog_date(worklog) do
    worklog |> Map.get("started") |> format_jira_date
  end

  @doc """
  Format jira datetime format to a simple YYYY-mm-dd format

  ## Example
    iex> Jrc.Formatter.format_jira_date("2017-10-02T16:42:00.000+0200")
    "2017-10-02"
  """
  def format_jira_date(jira_date) do
    jira_date
    |> Timex.parse!("{YYYY}-{M}-{D}T{h24}:{m}:{s}.000{Z}")
    |> DateTime.to_date
    |> Date.to_string
  end

end