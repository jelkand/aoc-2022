defmodule AdventOfCode.Day09 do
  alias AdventOfCode.Helpers

  def parse_instructions(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [dir, dist] -> {dir, Helpers.get_integer(dist)} end)
    |> Enum.flat_map(fn {dir, dist} -> List.duplicate(dir, dist) end)
  end

  def part1(args) do
    args
    |> parse_instructions()
    |> Enum.reduce(
      %{head_pos: {0, 0}, tail_pos: {0, 0}, seen_pos: MapSet.new([{0, 0}])},
      &handle_move/2
    )
    |> Map.get(:seen_pos)
    # |> pretty_print()
    |> MapSet.size()

    # |> IO.inspect()
  end

  def part2(args) do
  end

  def pretty_print(set) do
    max_x = Enum.max_by(set, fn {x, _} -> x end) |> Kernel.elem(0)
    max_y = Enum.max_by(set, fn {_, y} -> y end) |> Kernel.elem(1)

    IO.puts("\n")

    Enum.reduce(0..(max_y + 1), "", fn y, outer_acc ->
      Enum.reduce(0..(max_x + 1), "", fn x, acc ->
        cond do
          {x, y} == {0, 0} -> acc <> "s"
          MapSet.member?(set, {x, y}) -> acc <> "#"
          true -> acc <> "."
        end
      end) <> "\n" <> outer_acc
    end)
    |> IO.puts()

    set
  end

  def handle_move("R", acc) do
    acc
    |> Map.update!(:head_pos, fn {x, y} -> {x + 1, y} end)
    |> handle_tail()
  end

  def handle_move("L", acc) do
    acc
    |> Map.update!(:head_pos, fn {x, y} -> {x - 1, y} end)
    |> handle_tail()
  end

  def handle_move("U", acc) do
    acc
    |> Map.update!(:head_pos, fn {x, y} -> {x, y + 1} end)
    |> handle_tail()
  end

  def handle_move("D", acc) do
    acc
    |> Map.update!(:head_pos, fn {x, y} -> {x, y - 1} end)
    |> handle_tail()
  end

  def handle_tail(%{head_pos: {head_x, head_y}, tail_pos: {tail_x, tail_y} = tail_pos} = acc) do
    x_dist = head_x - tail_x
    y_dist = head_y - tail_y

    x_sign = Helpers.sign(x_dist)
    y_sign = Helpers.sign(y_dist)

    new_tail =
      case {Kernel.abs(x_dist), Kernel.abs(y_dist)} do
        {2, 1} ->
          {tail_x + x_sign * 1, tail_y + y_sign * 1}

        {1, 2} ->
          {tail_x + x_sign * 1, tail_y + y_sign * 1}

        {2, 0} ->
          {tail_x + x_sign * 1, tail_y}

        {0, 2} ->
          {tail_x, tail_y + y_sign * 1}

        _ ->
          tail_pos
      end

    acc
    |> Map.put(:tail_pos, new_tail)
    |> Map.update!(:seen_pos, fn set -> MapSet.put(set, new_tail) end)
  end
end
