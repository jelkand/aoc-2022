defmodule AdventOfCode.Day15 do
  alias AdventOfCode.Helpers

  def parse_sensor(str) do
    [x, y, beacon_x, beacon_y] =
      Regex.scan(~r"-?\d+", str) |> Enum.map(fn [x] -> Helpers.get_integer(x) end)

    distance = abs(x - beacon_x) + abs(y - beacon_y)
    {{x, y}, {beacon_x, beacon_y}, distance}
  end

  def merge_ranges(first_low..first_high, second_low..second_high) when first_high >= second_low,
    do: [min(first_low, second_low)..max(first_high, second_high)]

  def merge_ranges(first, second), do: [first, second]

  def reduce_ranges(range, []), do: [range]

  def reduce_ranges(first, [second | rest]) do
    merge_ranges(first, second) ++ rest
  end

  def can_merge_further?(ranges) do
    Helpers.permuations(ranges)
    |> Enum.any?(fn {a, b} -> !Range.disjoint?(a, b) end)
  end

  def merge_until_complete(ranges) do
    merged = Enum.reduce(ranges, [], &reduce_ranges/2)

    case can_merge_further?(merged) do
      true -> merge_until_complete(merged)
      false -> merged
    end
  end

  def part1(args, row) do
    sensors =
      String.split(args, "\n", trim: true)
      |> Enum.map(&parse_sensor/1)

    ranges =
      Enum.reduce(sensors, [], fn {{x, y}, _, distance}, acc ->
        unless abs(y - row) > distance do
          each_direction_on_row = div(1 + distance * 2 - 2 * abs(y - row), 2)
          [(x - each_direction_on_row)..(x + each_direction_on_row) | acc]
        else
          acc
        end
      end)
      |> Enum.sort(:desc)
      |> merge_until_complete()

    beacons_in_ranges =
      Enum.map(sensors, fn {_, b, _} -> b end)
      |> Enum.uniq()
      |> Enum.count(fn {x, y} ->
        y == row and Enum.any?(ranges, fn range -> x in range end)
      end)

    ranges
    |> Enum.reduce(0, fn range, acc -> acc + Range.size(range) end)
    |> Kernel.-(beacons_in_ranges)
  end

  def part2(args) do
  end
end
