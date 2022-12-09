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
end
