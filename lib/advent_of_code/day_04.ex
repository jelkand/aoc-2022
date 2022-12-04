defmodule AdventOfCode.Day04 do
  def parse_input(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&parse_pair/1)
    |> Enum.map(fn pair -> Enum.sort(pair, &sorter/2) end)
  end

  def sorter([one_low, one_high], [two_low, two_high]) do
    cond do
      one_low == two_low -> one_high <= two_high
      true -> one_low <= two_low
    end
  end

  def part1(args) do
    args
    |> parse_input()
    |> Enum.filter(&has_full_overlap/1)
    |> length()
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.filter(&has_some_overlap/1)
    |> length()
  end

  def has_full_overlap([[one_low, one_high], [two_low, two_high]]) do
    one_low == two_low or (one_high >= two_low and two_high <= one_high)
  end

  def has_some_overlap([[_, one_high], [two_low, _]]), do: one_high >= two_low

  def parse_pair(pair) do
    pair
    |> Enum.map(&parse_range/1)
  end

  def parse_range(string_range) do
    string_range
    |> String.split("-")
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&elem(&1, 0))
  end
end
