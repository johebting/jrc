defmodule JrcTest do
  use ExUnit.Case
  doctest Jrc

  test "greets the world" do
    assert Jrc.hello() == :world
  end
end
