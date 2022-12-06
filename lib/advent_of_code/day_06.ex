defmodule AdventOfCode.Day06 do
  def part1(args) do
    args
    |> String.split("", trim: true)
    |> find_start_of_packet(4)
  end

  def part2(args) do
    args
    |> String.split("", trim: true)
    |> find_start_of_packet(14)
  end

  def find_start_of_packet(input, packet_size) do
    group = Enum.take(input, packet_size)
    rest = input -- group
    _scan_string(group, rest, packet_size, packet_size)
  end

  def _scan_string(group, rest, count, packet_size) do
    cond do
      MapSet.new(group) |> MapSet.size() == packet_size ->
        count

      true ->
        [_ | group_tail] = group
        [rest_head | rest_tail] = rest
        _scan_string(group_tail ++ [rest_head], rest_tail, count + 1, packet_size)
    end
  end
end
