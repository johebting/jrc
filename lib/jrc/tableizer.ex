defmodule Jrc.Tableizer do

  alias TableRex.Table

  @moduledoc false

  @title "Inputs since "
  @header ["Date", "Issues", "Input", "Total"]
  @total_index 3

  def tableize(tree) do

    rows = trans(tree)

    IO.inspect(rows)

    # IO.inspect(rows)
    # Table.new(rows, @header, @title)
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

    if total_header != value && String.to_integer(value, 10) < limit do
      [:red, text]
    else
      text
    end
  end

  def trans(tree) do
    tree
    |> Enum.map(fn({date, inputs}) ->
      issues = inputs |> Map.keys
      times_spent = inputs |> Map.values
      total = times_spent |> Enum.sum

      [date, issues, times_spent, total]
    end)
  end
end
