defmodule AdventOfCode.Day05 do
  def parse_input(args) do
    [positions, moves] = String.split(args, "\n\n")

    parsed_positions = parse_positions(positions)
    parsed_moves = parse_moves(moves)

    {parsed_positions, parsed_moves}
  end

  def parse_positions(positions) do
    positions
    |> String.split("\n")
    |> normalize_length()
    |> Enum.map(&String.split(&1, ""))
    |> transpose()
    |> reverse()
    |> Enum.filter(fn [head | _] -> String.match?(head, ~r/\S/) end)
    |> Enum.map(fn row -> Enum.filter(row, &String.match?(&1, ~r/\S/)) end)
    |> Enum.reduce(%{}, fn [key | items], acc ->
      Map.put(acc, get_integer(key), Enum.reverse(items))
    end)
  end

  def parse_moves(moves) do
    moves
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&Regex.scan(~r/\d+/, &1))
    |> Enum.map(&format_move/1)
  end

  def normalize_length(positions) do
    size = positions |> Enum.max_by(&String.length/1) |> String.length()
    Enum.map(positions, &String.pad_trailing(&1, size))
  end

  def format_move(move) do
    move
    |> List.flatten()
    |> Enum.map(&get_integer/1)
    |> (fn [qty, from, to] -> {qty, from, to} end).()
  end

  def transpose(matrix) do
    matrix
    |> Enum.at(0)
    |> Enum.with_index()
    |> Enum.map(fn {_, idx} ->
      Enum.map(matrix, fn row ->
        Enum.at(row, idx)
      end)
    end)
  end

  def reverse(matrix) do
    matrix |> Enum.map(&Enum.reverse/1)
  end

  def get_integer(string) do
    string
    |> Integer.parse()
    |> case do
      {int, _} -> int
      _ -> nil
    end
  end

  def part1(args) do
    args
    |> parse_input()
    |> handle_moves()
    |> collect_top()
  end

  def part2(args) do
    args
    |> parse_input()
    |> handle_moves(&Enum.reverse/1)
    |> collect_top()
  end

  def collect_top(positions) do
    positions
    |> Enum.map(fn {key, [first | _]} -> {key, first} end)
    |> Enum.sort(fn key1, key2 -> key1 <= key2 end)
    |> Enum.reduce("", fn {_, val}, acc -> acc <> val end)
  end

  def handle_move(positions, {qty, from, to}, move_transformer) do
    {items, new_list} = positions |> Map.get(from) |> take(qty)

    transformed_items = items |> move_transformer.()

    Map.delete(positions, from)
    |> Map.put(from, new_list)
    |> Map.update!(to, fn list -> transformed_items ++ list end)
  end

  def take(list, count), do: take(list, count, [])

  def take(list, 0, items), do: {items, list}

  def take([item | rem], count, items) do
    new_count = count - 1
    new_items = [item | items]
    take(rem, new_count, new_items)
  end

  def handle_moves(input), do: handle_moves(input, fn x -> x end)

  def handle_moves({positions, []}, _) do
    positions
  end

  def handle_moves({positions, moves}, move_transformer) do
    [this_move | remaining_moves] = moves

    new_positions = handle_move(positions, this_move, move_transformer)

    handle_moves({new_positions, remaining_moves}, move_transformer)
  end
end
