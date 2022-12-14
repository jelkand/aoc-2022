defmodule AdventOfCode.Day14 do
  alias AdventOfCode.Helpers

  def parse_obstacles(args) do
    String.split(args, "\n", trim: true)
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.map(&format_points/1)
    |> Enum.map(&make_lines/1)
    |> List.flatten()
    |> MapSet.new()
  end

  def part1(args) do
    obstacles = parse_obstacles(args)

    bounds = get_bounds(obstacles)

    drop_sand(obstacles, bounds, 0)
  end

  def part2(args) do
    obstacles = parse_obstacles(args)

    {_, _, y_min, y_max} = get_bounds(obstacles)

    new_obstacles =
      ranges_to_points({0..1000, (y_max + 2)..(y_max + 2)})
      |> List.flatten()
      |> MapSet.new()
      |> MapSet.union(obstacles)

    drop_sand(new_obstacles, {0, 1000, y_min, y_max + 2}, 0)
  end

  def drop_sand(obstacles, bounds, count) do
    sand_pos = {500, 0}

    move_sand(sand_pos, obstacles, bounds)
    |> case do
      false -> count
      {500, 0} -> count + 1
      pos -> drop_sand(MapSet.put(obstacles, pos), bounds, count + 1)
    end
  end

  def move_sand({sand_x, sand_y}, obstacles, {x_min, x_max, y_min, y_max} = bounds)
      when sand_x >= x_min and
             sand_x <= x_max and
             sand_y >= y_min and
             sand_y <= y_max do
    get_move({sand_x, sand_y}, obstacles)
    |> case do
      nil -> {sand_x, sand_y}
      pos -> move_sand(pos, obstacles, bounds)
    end
  end

  def move_sand(_, _, _), do: false

  def get_move(sand_pos, obstacles) do
    possible_moves(sand_pos)
    |> Enum.find(fn pos -> !MapSet.member?(obstacles, pos) end)
  end

  def possible_moves({x, y}), do: [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]

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
    |> Enum.reduce([], fn ranges, acc -> acc ++ ranges_to_points(ranges) end)
  end

  def ranges_to_points({x_range, y_range}) do
    Enum.map(x_range, fn x_val -> Enum.map(y_range, fn y_val -> {x_val, y_val} end) end)
  end

  # def

  def pair_to_lines([{a, b}, {x, y}]), do: {min(a, x)..max(a, x), min(b, y)..max(b, y)}

  def get_bounds(obstacles) do
    x_min = Enum.min_by(obstacles, &elem(&1, 0)) |> elem(0)
    x_max = Enum.max_by(obstacles, &elem(&1, 0)) |> elem(0)
    y_max = Enum.max_by(obstacles, &elem(&1, 1)) |> elem(1)

    {x_min, x_max, 0, y_max}
  end
end
