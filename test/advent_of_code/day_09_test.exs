defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  test "tail handler" do
    input = %{head_pos: {2, 0}, tail_pos: {0, 0}, seen_pos: MapSet.new([{0, 0}])}

    result = handle_tail(input)

    assert result == %{head_pos: {2, 0}, tail_pos: {1, 0}, seen_pos: MapSet.new([{0, 0}, {1, 0}])}

    input = %{head_pos: {2, 4}, tail_pos: {4, 3}, seen_pos: MapSet.new([{4, 3}])}
    result = handle_tail(input)
    assert result == %{head_pos: {2, 4}, tail_pos: {3, 4}, seen_pos: MapSet.new([{4, 3}, {3, 4}])}
  end

  test "diagonal handler" do
    input = %{
      head_pos: {4, 3},
      seen_pos: MapSet.new([{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 1}]),
      tail_pos: {4, 1}
    }

    result = handle_tail(input)

    assert result == %{
             head_pos: {4, 3},
             seen_pos: MapSet.new([{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 1}, {4, 2}]),
             tail_pos: {4, 2}
           }
  end

  test "part1" do
    input = """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """

    result = part1(input)

    assert result == 13
  end

  test "part2" do
    input = """
    R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20
    """

    result = part2(input)

    assert result === 36
  end
end
