defmodule AdventOfCode.Day08 do
  alias AdventOfCode.Helpers

  def parse_input(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def add_indices(map) do
    map
    |> Enum.map(&Enum.with_index/1)
    |> Enum.with_index()
  end

  def map_to_int_map(map), do: Enum.map(map, fn row -> Enum.map(row, &Helpers.get_integer/1) end)

  def part1(args) do
    map = parse_input(args)

    rows = map |> add_indices() |> count_visible_in_rows()

    reversed_rows =
      map
      |> add_indices()
      |> Enum.map(fn {contents, idx} -> {Enum.reverse(contents), idx} end)
      |> count_visible_in_rows()

    transposed_rows =
      map
      |> Helpers.transpose()
      |> add_indices()
      |> count_visible_in_rows()
      |> MapSet.to_list()
      |> Enum.map(&swap_indices/1)
      |> MapSet.new()

    transposed_reversed_rows =
      map
      |> Helpers.transpose()
      |> add_indices()
      |> Enum.map(fn {contents, idx} -> {Enum.reverse(contents), idx} end)
      |> count_visible_in_rows()
      |> MapSet.to_list()
      |> Enum.map(&swap_indices/1)
      |> MapSet.new()

    MapSet.new()
    |> MapSet.union(rows)
    |> MapSet.union(reversed_rows)
    |> MapSet.union(transposed_rows)
    |> MapSet.union(transposed_reversed_rows)
    |> MapSet.size()
  end

  def part2(args) do
    map =
      parse_input(args)
      |> map_to_int_map()

    rows =
      map
      |> add_indices()
      |> score_rows()

    reversed_rows =
      map
      |> add_indices()
      |> Enum.map(fn {contents, idx} -> {Enum.reverse(contents), idx} end)
      |> score_rows()

    transposed_rows =
      map
      |> Helpers.transpose()
      |> add_indices()
      |> score_rows()
      |> Enum.map(&swap_map_indices/1)
      |> Map.new()

    transposed_reversed_rows =
      map
      |> Helpers.transpose()
      |> add_indices()
      |> Enum.map(fn {contents, idx} -> {Enum.reverse(contents), idx} end)
      |> score_rows()
      |> Enum.map(&swap_map_indices/1)
      |> Map.new()

    Map.new()
    |> Map.merge(rows, &score_merger/3)
    |> Map.merge(reversed_rows, &score_merger/3)
    |> Map.merge(transposed_rows, &score_merger/3)
    |> Map.merge(transposed_reversed_rows, &score_merger/3)
    |> Enum.max_by(fn {_k, v} -> v end)
    |> Kernel.elem(1)
  end

  def score_merger(_k, v1, v2), do: v1 * v2

  # after being transposed row and col indices will be swapped
  def swap_indices({outer, inner}), do: {inner, outer}
  def swap_map_indices({{outer, inner}, v}), do: {{inner, outer}, v}

  def count_visible_in_rows(map) do
    Enum.reduce(map, MapSet.new(), fn r, acc ->
      MapSet.union(acc, count_visible_in_row(r))
    end)
  end

  def count_visible_in_row({contents, index}) do
    contents
    |> Enum.reduce(%{max: -1, visible: MapSet.new()}, fn {height, inner_index}, acc ->
      acc
      |> Map.update!(:visible, fn vis ->
        if height > acc.max,
          do: MapSet.put(vis, {index, inner_index}),
          else: vis
      end)
      |> Map.update!(:max, &Kernel.max(&1, height))
    end)
    |> Map.get(:visible)
  end

  def score_rows(map) do
    Enum.reduce(map, Map.new(), fn r, acc ->
      Map.merge(acc, score_row(r))
    end)
  end

  def score_row({contents, index}) do
    contents
    |> Enum.reduce(%{height_distances: %{99 => 0}, scores: %{}}, fn {height, inner_index}, acc ->
      score = get_score(acc.height_distances, height)

      new =
        acc.height_distances
        |> Map.put(height, 0)
        |> Enum.map(fn {k, v} -> {k, v + 1} end)
        |> Map.new()

      acc
      |> Map.put(:height_distances, new)
      |> Kernel.put_in([:scores, {index, inner_index}], score)
    end)
    |> Map.get(:scores)
  end

  def get_score(height_distances, height) do
    height_distances
    |> Enum.filter(fn {k, _} ->
      k >= height
    end)
    |> Enum.min_by(fn t -> Kernel.elem(t, 1) end)
    |> Kernel.elem(1)
  end
end
