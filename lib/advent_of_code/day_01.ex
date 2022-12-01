defmodule AdventOfCode.Day01 do
  def parse(args) do
    args
    |> String.trim("\n")
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n"))
    |> Enum.map(&sum_cal_array(&1))
    |> Enum.sort(:desc)
  end

  def part1(args) do
    args
    |> parse()
    |> Enum.at(0)
  end

  def part2(args) do
    args
    |> parse()
    |> Enum.take(3)
    |> Enum.sum()
  end

  def sum_cal_array(cal_array) do
    cal_array
    |> Enum.map(&cal_string_to_integer(&1))
    |> Enum.sum()
  end

  def cal_string_to_integer(cal_string) do
    cal_string
    |> Integer.parse()
    |> case do
      {int, _} -> int
      _ -> nil
    end
  end
end
