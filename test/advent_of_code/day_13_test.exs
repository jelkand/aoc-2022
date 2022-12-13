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

  test "complicated arrays" do
    assert compare(
             [[], [1, [3, [0]]], []],
             [
               [],
               [
                 [0, [5, 3, 0, 1, 0], [3, 0, 5, 7], 10, [2, 8, 5, 0]],
                 10,
                 [2, 4, [1], [5, 6, 7], []],
                 []
               ]
             ]
           ) > 0
  end

  test "parse list string" do
    assert parse_strings("[1,1,3,1,1]\n[1,1,5,1,1]") == {[1, 1, 3, 1, 1], [1, 1, 5, 1, 1]}
  end

  test "parse nested list string" do
    assert parse_strings("[[1],[2,3,4]]\n[[1],4]") == {[[1], [2, 3, 4]], [[1], 4]}
  end

  @tag :skip
  test "lists in order" do
    assert compare([1, 1, 3, 1, 1], [1, 1, 5, 1, 1]) < 0
  end

  @tag :skip
  test "nested lists in order" do
    assert compare([[1], [2, 3, 4]], [[1], 4]) < 0
  end

  @tag :skip
  test "left runs out first 1" do
    assert compare([4, 4], [4, 4, 4]) < 0
  end

  @tag :skip
  test "left runs out first 2" do
    assert compare([[4, 4], 4, 4], [[4, 4], 4, 4, 4]) < 0
  end

  @tag :skip
  test "part1" do
    result = part1(@input)

    assert result == 13
  end

  test "part2" do
    result = part2(@input)

    assert result == 140
  end
end
