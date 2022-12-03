defmodule AdventOfCode.Day03 do
  def part1(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&split_half/1)
    |> Enum.flat_map(&handle_bag/1)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&to_set/1)
    |> Enum.chunk_every(3)
    |> Enum.flat_map(&handle_group/1)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def score(char) do
    char
    |> :binary.first()
    |> score_char()
  end

  def score_char(char) when char in 97..122 do
    char - 96
  end

  def score_char(char) when char in 65..90 do
    char - 64 + 26
  end

  def handle_group(group) do
    Enum.reduce(group, fn ele, acc -> MapSet.intersection(ele, acc) end)
    |> MapSet.to_list()
  end

  def handle_bag({left, right}) do
    left_set = to_set(left)
    right_set = to_set(right)

    MapSet.intersection(left_set, right_set)
    |> MapSet.to_list()
  end

  def split_half(string) do
    pivot = div(String.length(string), 2)
    String.split_at(string, pivot)
  end

  def to_set(string) do
    string
    |> String.split("")
    |> MapSet.new()
    |> MapSet.delete("")
  end
end
