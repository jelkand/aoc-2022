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

  def permuations(input) do
    Enum.flat_map(input, fn x ->
      Enum.map(input, fn y ->
        {x, y}
      end)
    end)
    |> Enum.filter(fn {x, y} -> x != y end)
  end
end
