defmodule AdventOfCode.Day15 do
  alias AdventOfCode.Helpers

  def parse_sensor(str) do
    [x, y, beacon_x, beacon_y] =
      Regex.scan(~r"-?\d+", str) |> Enum.map(fn [x] -> Helpers.get_integer(x) end)

    distance = abs(x - beacon_x) + abs(y - beacon_y)
    {{x, y}, {beacon_x, beacon_y}, distance}
  end

  def merge_ranges(first_low..first_high = first, second_low..second_high = second) do
    case Range.disjoint?(first, second) do
      false -> [min(first_low, second_low)..max(first_high, second_high)]
      true -> [first, second]
    end
  end

  def reduce_ranges(range, []), do: [range]

  def reduce_ranges(first, [second | rest]) do
    # IO.inspect({first, second}, label: "reducing")
    merge_ranges(first, second) ++ rest
  end

  def can_merge_further?(ranges) do
    Helpers.permute_pairs(ranges)
    |> Enum.any?(fn {a, b} -> !Range.disjoint?(a, b) end)
  end

  def merge_until_complete(ranges) do
    merged =
      Enum.sort(ranges, :desc)
      |> Enum.reduce([], &reduce_ranges/2)

    case can_merge_further?(merged) do
      true -> merge_until_complete(merged)
      false -> merged
    end
  end

  def ranges_for_row(sensors, row) do
    Enum.reduce(sensors, [], fn {{x, y}, _, distance}, acc ->
      unless abs(y - row) > distance do
        each_direction_on_row = div(1 + distance * 2 - 2 * abs(y - row), 2)
        [(x - each_direction_on_row)..(x + each_direction_on_row) | acc]
      else
        acc
      end
    end)
    |> Enum.sort(:asc)
    |> merge_until_complete()
  end

  def ranges_for_sensor({{x, y}, _, distance}, low..high) do
    Enum.map(max(low, y - distance)..min(high, y + distance), fn row ->
      each_direction_on_row = div(1 + distance * 2 - 2 * abs(y - row), 2)
      {row, max(low, x - each_direction_on_row)..min(high, x + each_direction_on_row)}
    end)
    |> Map.new()
  end

  def range_finder({_, [_]}), do: false
  def range_finder({_, [_..low, high.._]}), do: high - low > 1

  def get_frequency({y, [_..x, _]}), do: (x + 1) * 4_000_000 + y

  def part1(args, row) do
    sensors =
      String.split(args, "\n", trim: true)
      |> Enum.map(&parse_sensor/1)

    ranges = ranges_for_row(sensors, row)

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

  def part2(args, size) do
    sensors =
      String.split(args, "\n", trim: true)
      |> Enum.map(&parse_sensor/1)

    # |> IO.inspect(label: "sensors")

    # Enum.reduce(sensors, %{}, fn sensor, acc ->
    #   ranges_for_sensor(sensor, 0..size)
    #   |> Map.merge(acc, fn _k, v1, v2 ->
    #     merge_until_complete(List.flatten([v1, v2]))
    #   end)
    # end)
    # |> Enum.map(fn {row, ranges} -> {row, Enum.sort(ranges, :asc)} end)
    # |> Enum.filter(fn {row, _} -> row in 0..size end)
    # |> Enum.sort(:asc)
    # |> Enum.find(&range_finder/1)
    # |> get_frequency()

    # |> IO.inspect(label: "other approach")

    Enum.map(0..size, fn row -> {row, ranges_for_row(sensors, row)} end)
    |> Enum.map(fn {row, ranges} -> {row, Enum.sort(ranges, :asc)} end)
    |> Enum.find(&range_finder/1)
    |> get_frequency()
  end
end
