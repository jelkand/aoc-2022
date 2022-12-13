defmodule AdventOfCode.Day13Test do
  use ExUnit.Case

  import AdventOfCode.Day13

  @input """
  [1,1,3,1,1]
  [1,1,5,1,1]

  [[1],[2,3,4]]
  [[1],4]

  [9]
  [[8,7,6]]

  [[4,4],4,4]
  [[4,4],4,4,4]

  [7,7,7,7]
  [7,7,7]

  []
  [3]

  [[[]]]
  [[]]

  [1,[2,[3,[4,[5,6,7]]]],8,9]
  [1,[2,[3,[4,[5,6,0]]]],8,9]
  """

  test "parse list string" do
    assert parse_strings("[1,1,3,1,1]\n[1,1,5,1,1]") == {[1, 1, 3, 1, 1], [1, 1, 5, 1, 1]}
  end

  test "parse nested list string" do
    assert parse_strings("[[1],[2,3,4]]\n[[1],4]") == {[[1], [2, 3, 4]], [[1], 4]}
  end

  test "lists in order" do
    assert compare({[1, 1, 3, 1, 1], [1, 1, 5, 1, 1]}) < 0
  end

  test "nested lists in order" do
    assert compare({[[1], [2, 3, 4]], [[1], 4]}) < 0
  end

  test "left runs out first 1" do
    assert compare({[4, 4], [4, 4, 4]}) < 0
  end

  test "left runs out first 2" do
    assert compare({[[4, 4], 4, 4], [[4, 4], 4, 4, 4]}) < 0
  end

  test "part1" do
    result = part1(@input)

    assert result == 13
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
