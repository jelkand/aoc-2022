defmodule AdventOfCode.Day15 do
  alias AdventOfCode.Helpers

  def parse_sensor(str) do
    [x, y, beacon_x, beacon_y] =
      Regex.scan(~r"-?\d+", str) |> Enum.map(fn [x] -> Helpers.get_integer(x) end)

    distance = abs(x - beacon_x) + abs(y - beacon_y)
    {{x, y}, {beacon_x, beacon_y}, distance}
  end

  def part1(args, row) do
    sensors =
      String.split(args, "\n", trim: true)
      |> Enum.map(&parse_sensor/1)

    beacons =
      Enum.map(sensors, &elem(&1, 1))
      |> MapSet.new()

    Enum.reduce(sensors, MapSet.new(), fn {{x, y}, _, distance}, acc ->
      unless abs(y - row) > distance do
        each_direction_on_row = div(1 + distance * 2 - 2 * abs(y - row), 2)

        points =
          Helpers.ranges_to_points(
            {(x - each_direction_on_row)..(x + each_direction_on_row), row..row}
          )
          |> List.flatten()
          |> MapSet.new()

        MapSet.union(acc, points)
      else
        acc
      end
    end)
    |> MapSet.difference(beacons)
    |> IO.inspect()
    |> MapSet.size()
  end

  def part2(args) do
  end
end
