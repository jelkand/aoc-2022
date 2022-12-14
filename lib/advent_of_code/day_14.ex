defmodule AdventOfCode.Day14 do
  alias AdventOfCode.Helpers

  def part1(args) do
    lines =
      String.split(args, "\n", trim: true)
      |> Enum.map(&String.split(&1, " -> "))
      |> Enum.map(&format_points/1)
      |> Enum.map(&make_lines/1)
      |> List.flatten()
      |> IO.inspect()

    {x_range, y_range} = get_bounds(lines) |> IO.inspect()
  end

  def part2(args) do
  end

  def format_points(path) do
    Enum.map(path, fn str ->
      String.split(str, ",")
      |> Enum.map(&Helpers.get_integer/1)
      |> List.to_tuple()
    end)
  end

  def make_lines(path) do
    Enum.chunk_every(path, 2, 1, :discard)
    |> Enum.map(&pair_to_lines/1)
  end

  def pair_to_lines([{a, b}, {x, y}]), do: {min(a, x)..max(a, x), min(b, y)..max(b, y)}

  def get_bounds(lines) do
    x_min = Enum.min_by(lines, &get_lower_x/1) |> get_lower_x()
    x_max = Enum.max_by(lines, &get_upper_x/1) |> get_upper_x()
    y_max = Enum.max_by(lines, &get_upper_y/1) |> get_upper_y()

    {x_min..x_max, 0..y_max}
  end

  def get_lower_x({x.._, _}), do: x
  def get_upper_x({_..x, _}), do: x
  def get_lower_y({_, y.._}), do: y
  def get_upper_y({_, _..y}), do: y
end
