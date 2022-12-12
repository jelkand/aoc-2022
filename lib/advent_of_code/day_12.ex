defmodule AdventOfCode.Day12 do
  @infinity 999_999_999
  def find_start_end(string, row_size) do
    {start_marker, _} = :binary.match(string, "S")
    {end_marker, _} = :binary.match(string, "E")

    {{div(start_marker, row_size), rem(start_marker, row_size)},
     {div(end_marker, row_size), rem(end_marker, row_size)}}
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

  def are_neighbors?(position_height, neighbor, height_map) do
    Map.has_key?(height_map, neighbor) and
      Map.get(height_map, neighbor)
      |> :binary.first()
      |> Kernel.in(?a..(:binary.first(position_height) + 1))
  end

  def get_neighbor_positions({row, col}),
    do: [{row + 1, col}, {row, col + 1}, {row - 1, col}, {row, col - 1}]

  def djikstras(adjacency_list, start, goal) do
    unvisited = Map.keys(adjacency_list) |> MapSet.new()
    visited = MapSet.new()

    distances =
      Map.keys(adjacency_list)
      |> Enum.map(fn pos -> {pos, @infinity} end)
      |> Map.new()
      |> Map.update!(start, fn _ -> 0 end)

    djikstras_internal(start, goal, adjacency_list, distances, visited, unvisited)
  end

  defp djikstras_internal(current, goal, _, distances, _, _) when current == goal do
    Map.put(distances, goal, distances[current])
  end

  defp djikstras_internal(_, _, _, distances, _, unvisited)
       when unvisited == %MapSet{} do
    distances
  end

  defp djikstras_internal(current, goal, adj_list, distances, visited, unvisited) do
    new_distances =
      adj_list[current]
      |> Enum.map(fn neighbor -> {neighbor, distances[current] + 1} end)
      |> Map.new()
      |> Map.merge(distances, fn _k, v1, v2 -> Kernel.min(v1, v2) end)

    MapSet.put(visited, current)
    MapSet.delete(unvisited, current)

    new_current = Enum.min_by(unvisited, fn pos -> distances[pos] end)

    djikstras_internal(
      new_current,
      goal,
      adj_list,
      new_distances,
      MapSet.put(visited, current),
      MapSet.delete(unvisited, current)
    )
  end

  def part1(args) do
    row_length = :binary.match(args, "\n") |> Kernel.elem(0)

    without_breaks = String.replace(args, "\n", "")

    {start_pos, end_pos} = find_start_end(without_breaks, row_length)

    # adj_list =
    to_height_map(without_breaks, row_length)
    |> to_adj_list()
    |> djikstras(start_pos, end_pos)
    |> Map.get(end_pos)
  end

  def part2(args) do
  end
end
