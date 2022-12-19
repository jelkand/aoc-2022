defmodule AdventOfCode.Helpers do
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

  def points_within_distance(x, y, 0) do
    MapSet.new([{x, y}])
  end

  def points_within_distance(x, y, distance) do
    MapSet.new([{x, y}])
    |> MapSet.union(points_within_distance(x + 1, y, distance - 1))
    |> MapSet.union(points_within_distance(x - 1, y, distance - 1))
  end

  def get_integer(string) do
    string
    |> Integer.parse()
    |> case do
      {int, _} -> int
      _ -> nil
    end
  end

  def sign(int) when int >= 0, do: 1
  def sign(int) when int < 0, do: -1

  @doc """
    Takes in a tuple of two ranges and returns all points belonging to both.
  """
  def ranges_to_points({x_range, y_range}) do
    Enum.map(x_range, fn x_val -> Enum.map(y_range, fn y_val -> {x_val, y_val} end) end)
  end

  def permute_pairs(input) do
    Enum.flat_map(input, fn x ->
      Enum.map(input, fn y ->
        {x, y}
      end)
    end)
    |> Enum.filter(fn {x, y} -> x != y end)
  end

  def permute_list([]), do: [[]]

  def permute_list(list) do
    for h <- list, t <- permute_list(list -- [h]), do: [h | t]
  end

  def pairs_of([], right) do
    Enum.map(right, fn r -> {nil, r} end)
  end

  def pairs_of(left, []) do
    Enum.map(left, fn l -> {l, nil} end)
  end

  def pairs_of(left, right) do
    for l <- left, r <- right, do: {l, r}
  end

  @infinity 999_999_999
  def djikstras(adjacency_list, start, goal \\ nil) do
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
end
