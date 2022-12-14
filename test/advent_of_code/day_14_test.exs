defmodule AdventOfCode.Day14Test do
  use ExUnit.Case

  import AdventOfCode.Day14

  @input """
  498,4 -> 498,6 -> 496,6
  503,4 -> 502,4 -> 502,9 -> 494,9
  """

  @tag :skip
  test "part1" do
    assert part1(@input) == 24
  end

  test "part2" do
    assert part2(@input) == 93
  end
end
