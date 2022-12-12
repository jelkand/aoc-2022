defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  @input """
  Sabqponm
  abcryxxl
  accszExk
  acctuvwj
  abdefghi
  """

  test "adjacency list inverter" do
    input = %{
      "a" => ["b", "c"]
    }

    result = invert_adj_list(input)

    assert result == %{
             "b" => ["a"],
             "c" => ["a"]
           }
  end

  test "part1" do
    result = part1(@input)

    assert result == 31
  end

  test "part2" do
    result = part2(@input)

    assert result == 29
  end
end
