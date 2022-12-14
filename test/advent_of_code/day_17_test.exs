defmodule AdventOfCode.Day17Test do
  use ExUnit.Case

  import AdventOfCode.Day17

  @tag :skip
  test "part1" do
    input = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
    result = part1(input)

    assert result
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
