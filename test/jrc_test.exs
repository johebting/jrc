defmodule JrcTest do
  use ExUnit.Case
  doctest Jrc

  test "application launch" do
    assert Jrc.start(:a, :b) == nil
  end
end
