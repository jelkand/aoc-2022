defmodule AdventOfCode.Day12 do
  @infinity 999_999_999
  def find_start_end(string, row_size) do
    {start_marker, _} = :binary.match(string, "S")
    {end_marker, _} = :binary.match(string, "E")

    {index_to_pos(start_marker, row_size), index_to_pos(end_marker, row_size)}
  end

  def find_end(string, row_size) do
    {start_marker, _} = :binary.match(string, "E")
    index_to_pos(start_marker, row_size)
  end

  def find_all_starts(str, row_size) do
    String.split(str, "", trim: true)
    |> Enum.with_index()
    |> Enum.filter(fn {height, _} -> height == "a" end)
    |> Enum.map(fn {_, idx} -> index_to_pos(idx, row_size) end)
    |> MapSet.new()
  end

  def index_to_pos(index, row_size), do: {div(index, row_size), rem(index, row_size)}

  def replace_special_char("S"), do: "a"
  def replace_special_char("E"), do: "z"

  def to_height_map(str, row_size) do
    String.replace(str, ~r"S|E", &replace_special_char/1)
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {ele, idx} -> {index_to_pos(idx, row_size), ele} end)
    |> Map.new()
  end

  def to_adj_list(height_map) do
    Enum.map(height_map, fn {position, height} ->
      {position,
       Enum.filter(get_neighbor_positions(position), fn neighbor ->
         are_neighbors?(height, neighbor, height_map)
       end)}
    end)
    |> Map.new()
  end

  def invert_adj_list(adj_list) do
    Enum.reduce(adj_list, %{}, fn {pos, adjacents}, acc ->
      Enum.reduce(adjacents, acc, fn adj, inner_acc ->
        Map.update(inner_acc, adj, [pos], fn item ->
          item ++ [pos]
        end)
      end)
    end)
  end

  def are_neighbors?(position_height, neighbor, height_map) do
    Map.has_key?(height_map, neighbor) and
      Map.get(height_map, neighbor)
      |> :binary.first()
      |> Kernel.in(?a..(:binary.first(position_height) + 1))
  end

  def get_neighbor_positions({row, col}),
    do: [{row + 1, col}, {row, col + 1}, {row - 1, col}, {row, col - 1}]

  def djikstras(adjacency_list, start, goal) do
    to_visit_tracker = MapSet.new()
    to_visit = [start]
    visited = MapSet.new()

    distances =
      Map.keys(adjacency_list)
      |> Enum.map(fn pos -> {pos, @infinity} end)
      |> Map.new()
      |> Map.update!(start, fn _ -> 0 end)

    djikstras_internal(to_visit, goal, adjacency_list, distances, visited, to_visit_tracker)
  end

  defp djikstras_internal([current | _], goal, _, distances, _, _) when current == goal do
    Map.put(distances, goal, distances[current])
  end

  defp djikstras_internal([], _, _, distances, _, _) do
    distances
  end

  defp djikstras_internal([current | rest], goal, adj_list, distances, visited, to_visit_tracker) do
    new_distances =
      Map.get(adj_list, current, [])
      |> Enum.map(fn neighbor -> {neighbor, distances[current] + 1} end)
      |> Map.new()
      |> Map.merge(distances, fn _k, v1, v2 -> Kernel.min(v1, v2) end)

    new_visited = MapSet.put(visited, current)

    to_visit =
      Map.get(adj_list, current, [])
      |> Enum.filter(fn neighbor ->
        !MapSet.member?(new_visited, neighbor) and !MapSet.member?(to_visit_tracker, neighbor)
      end)

    djikstras_internal(
      rest ++ to_visit,
      goal,
      adj_list,
      new_distances,
      new_visited,
      MapSet.union(to_visit_tracker, MapSet.new(to_visit))
    )
  end

  def part1(args) do
    row_length = :binary.match(args, "\n") |> Kernel.elem(0)

    without_breaks = String.replace(args, "\n", "")

    {start_pos, end_pos} = find_start_end(without_breaks, row_length)

    to_height_map(without_breaks, row_length)
    |> to_adj_list()
    |> djikstras(start_pos, end_pos)
    |> Map.get(end_pos)
  end

  def part2(args) do
    row_length = :binary.match(args, "\n") |> Kernel.elem(0)
    without_breaks = String.replace(args, "\n", "")

    end_pos = find_end(without_breaks, row_length)
    starts = find_all_starts(without_breaks, row_length)

    to_height_map(without_breaks, row_length)
    |> to_adj_list()
    |> invert_adj_list()
    |> djikstras(end_pos, nil)
    |> Enum.filter(fn {k, _} -> MapSet.member?(starts, k) end)
    |> Enum.min_by(fn {_, v} -> v end)
    |> Kernel.elem(1)
  end
end
