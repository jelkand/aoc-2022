defmodule AdventOfCode.Day16Test do
  use ExUnit.Case
  alias AdventOfCode.Helpers
  import AdventOfCode.Day16

  @input """
  Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
  Valve BB has flow rate=13; tunnels lead to valves CC, AA
  Valve CC has flow rate=2; tunnels lead to valves DD, BB
  Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
  Valve EE has flow rate=3; tunnels lead to valves FF, DD
  Valve FF has flow rate=0; tunnels lead to valves EE, GG
  Valve GG has flow rate=0; tunnels lead to valves FF, HH
  Valve HH has flow rate=22; tunnel leads to valve GG
  Valve II has flow rate=0; tunnels lead to valves AA, JJ
  Valve JJ has flow rate=21; tunnel leads to valve II
  """

  test "permute list" do
    assert Helpers.permute_list([1, 2, 3]) |> MapSet.new() ==
             MapSet.new([
               [1, 2, 3],
               [1, 3, 2],
               [2, 1, 3],
               [2, 3, 1],
               [3, 2, 1],
               [3, 1, 2]
             ])
  end

  test "part1" do
    assert part1(@input) == 1651
  end

  test "part2" do
    assert part2(@input) == 1707
  end
end
