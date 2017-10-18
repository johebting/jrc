defmodule Jrc.Tableizer do

  alias TableRex.Table

  @moduledoc false

  @title "JIRA Report"
  @header ["Date", "Issues", "Input", "Total"]
  @total_index 3

  def tableize(tree) do
    rows = trans(tree)

    Table.new
    |> Table.put_title(@title)
    |> Table.put_header(@header)
    |> Table.add_rows(rows)
    |> Table.put_column_meta(3, color: &colorize_total_value(&1, &2))
    |> Table.render!
    |> IO.puts
  end

  def colorize_total_value(text, value) do
    limit = Application.get_env(:jrc, :max_daily_input)
    total_header = Enum.fetch!(@header, @total_index)

    if total_header != value && "" != String.trim(value) && String.to_integer(value, 10) < limit do
      [:red, text]
    else
      text
    end
  end

  def trans(tree) do
    tree
    |> Enum.reduce([], fn(branch, acc) ->
      
      date = elem(branch, 0)
      inputs = elem(branch, 1)
      total_time = inputs |> Map.values |> Enum.sum

      [first_input | other_inputs] = inputs |> Map.to_list

      acc
      |> Kernel.++(
        [[date, elem(first_input, 0), elem(first_input, 1), total_time]]
      )
      |> Kernel.++(
        other_inputs |> Enum.map(&([nil, elem(&1, 0), elem(&1, 1), nil]))
      )
    end)
  end
end
