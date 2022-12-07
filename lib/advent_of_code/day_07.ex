defmodule AdventOfCode.Day07 do
  @max_available 70_000_000

  @needed_space 30_000_000

  def build_tree(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce(%{current_dir: []}, &handle_command/2)
    |> complete_tree()
    |> Map.delete(:current_dir)
    |> Enum.map(fn {_, value} -> value end)
    |> Enum.sort(:desc)
  end

  def complete_tree(tree = %{current_dir: ["/"]}) do
    tree
  end

  def complete_tree(tree) do
    handle_command(["$", "cd", ".."], tree)
    |> complete_tree()
  end

  def part1(args) do
    args
    |> build_tree()
    |> Enum.filter(fn val -> val <= 100_000 end)
    |> Enum.sum()
  end

  def part2(args) do
    [total_used | _] = directory = build_tree(args)

    needed_to_free =
      (@needed_space - (@max_available - total_used)) |> IO.inspect(label: "needed")

    directory
    |> Enum.reverse()
    |> Enum.filter(fn size -> size >= needed_to_free end)
    |> Enum.min()
  end

  def to_index(current_dir), do: Enum.join(current_dir, ":")

  def handle_command(["$", "cd", ".."], acc) do
    size = Map.get(acc, to_index(acc.current_dir))

    one_up =
      Map.get(acc, :current_dir)
      |> List.delete_at(-1)

    acc
    |> Map.update(Enum.join(one_up, ":"), 0, &(&1 + size))
    |> Map.update!(:current_dir, &List.delete_at(&1, -1))
  end

  def handle_command(["$", "cd", dir_name], acc) do
    Map.update!(acc, :current_dir, &(&1 ++ [dir_name]))
  end

  def handle_command(["$", "ls"], acc) do
    Map.put(acc, to_index(acc.current_dir), 0)
  end

  def handle_command(["dir", dir_name], acc) do
    Map.put(acc, to_index(acc.current_dir ++ [dir_name]), 0)
  end

  def handle_command([size, _], acc) do
    Map.update(
      acc,
      to_index(acc.current_dir),
      0,
      &(&1 + get_integer(size))
    )
  end

  def get_integer(string) do
    string
    |> Integer.parse()
    |> case do
      {int, _} -> int
      _ -> nil
    end
  end
end
