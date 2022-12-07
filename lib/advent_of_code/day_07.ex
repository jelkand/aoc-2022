defmodule AdventOfCode.Day07 do
  def build_tree(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce(%{current_dir: []}, &handle_command/2)
  end

  def complete_tree(tree = %{current_dir: current_dir}) when current_dir == "/" do
    tree
  end

  def complete_tree(tree) do
    handle_command(["$", "cd", ".."], tree)
  end

  def part1(args) do
    args
    |> build_tree()
    |> complete_tree()
    |> Map.delete(:current_dir)
    |> IO.inspect()

    # |> dirs_to_size()
  end

  def part2(args) do
  end

  def handle_command(["$", "cd", ".."], acc) do
    files_size = Kernel.get_in(acc, acc.current_dir ++ [:files_size])
    IO.inspect(files_size, label: acc.current_dir)

    acc
    |> Map.update!(:current_dir, &List.delete_at(&1, -1))
    |> Kernel.put_in(
      acc.current_dir ++ [:size],
      files_size + Kernel.get_in(acc, acc.current_dir ++ [:files_size])
    )
  end

  def handle_command(["$", "cd", dir_name], acc),
    do: Map.update!(acc, :current_dir, &(&1 ++ [dir_name]))

  # doesn't seem to be necessary right now?
  def handle_command(["$", "ls"], acc),
    do: Kernel.put_in(acc, acc.current_dir, %{files_size: 0, files: []})

  def handle_command(["dir", dir_name], acc),
    do: Kernel.put_in(acc, acc.current_dir ++ [dir_name], %{})

  def handle_command([size, name], acc),
    do: Kernel.update_in(acc, acc.current_dir ++ [:files], &(&1 ++ [{name, get_integer(size)}]))

  # |> Kernel.update_in(acc.current_dir ++ [:files_size], &(&1 + get_integer(size)))

  def get_integer(string) do
    string
    |> Integer.parse()
    |> case do
      {int, _} -> int
      _ -> nil
    end
  end
end
