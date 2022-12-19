defmodule AdventOfCode.HelpersTest do
  use ExUnit.Case

  import AdventOfCode.Helpers

  test "pairs of" do
    assert pairs_of([1, 2], [3, 4]) |> MapSet.new() ==
             MapSet.new([{1, 3}, {1, 4}, {2, 3}, {2, 4}])
  end

  test "pairs of empty" do
    assert pairs_of([1, 2], []) |> MapSet.new() ==
             MapSet.new([{1, nil}, {2, nil}])
  end
end
