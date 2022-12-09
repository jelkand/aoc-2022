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
    # |> pretty_print("part1.txt")
    |> MapSet.size()
  end

  def part2(args) do
    args
    |> parse_instructions()
    |> Enum.reduce(
      %{
        positions: List.duplicate({0, 0}, 10),
        seen_pos: MapSet.new()
      },
      &reduce_multiple/2
    )
    |> Map.get(:seen_pos)
    # |> pretty_print("part2.txt")
    |> MapSet.size()
  end

  def reduce_multiple(instruction, %{positions: [head | rest]} = acc) do
    new_head = apply_instruction(instruction, head)

    [last | _] =
      updated_reversed_list =
      Enum.reduce(rest, [new_head], fn ele, acc ->
        [apply_move_to_next(List.first(acc), ele) | acc]
      end)

    acc
    |> Map.update!(:seen_pos, fn set -> MapSet.put(set, last) end)
    |> Map.put(:positions, Enum.reverse(updated_reversed_list))
  end

  def pretty_print(set, filename) do
    min_x = Enum.min_by(set, fn {x, _} -> x end) |> Kernel.elem(0)
    min_y = Enum.min_by(set, fn {_, y} -> y end) |> Kernel.elem(1)
    max_x = Enum.max_by(set, fn {x, _} -> x end) |> Kernel.elem(0)
    max_y = Enum.max_by(set, fn {_, y} -> y end) |> Kernel.elem(1)

    IO.puts("\n")

    {:ok, file} = File.open(filename, [:write])

    text =
      Enum.reduce(min_y..(max_y + 1), "", fn y, outer_acc ->
        Enum.reduce(min_x..(max_x + 1), "", fn x, acc ->
          cond do
            {x, y} == {0, 0} -> acc <> "s"
            MapSet.member?(set, {x, y}) -> acc <> "#"
            true -> acc <> "."
          end
        end) <> "\n" <> outer_acc
      end)

    IO.binwrite(file, text)
    File.close(file)
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

  def apply_instruction(instruction, {x, y}) do
    case instruction do
      "R" -> {x + 1, y}
      "L" -> {x - 1, y}
      "U" -> {x, y + 1}
      "D" -> {x, y - 1}
    end
  end

  def apply_move_to_next({x1, y1}, {x2, y2}) do
    x_dist = x1 - x2
    y_dist = y1 - y2

    x_sign = Helpers.sign(x_dist)
    y_sign = Helpers.sign(y_dist)

    case {Kernel.abs(x_dist), Kernel.abs(y_dist)} do
      {2, 1} ->
        {x2 + x_sign * 1, y2 + y_sign * 1}

      {1, 2} ->
        {x2 + x_sign * 1, y2 + y_sign * 1}

      {2, 2} ->
        {x2 + x_sign * 1, y2 + y_sign * 1}

      {2, 0} ->
        {x2 + x_sign * 1, y2}

      {0, 2} ->
        {x2, y2 + y_sign * 1}

      _ ->
        {x2, y2}
    end
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
