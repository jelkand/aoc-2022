defmodule AdventOfCode.Day10 do
  alias AdventOfCode.Helpers

  def parse_input(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    # {cycle, value}
    |> Enum.reduce([{1, 1}], &handle_instruction/2)
    |> Enum.reverse()
  end

  def part1(args) do
    args
    |> parse_input()
    |> score([20, 60, 100, 140, 180, 220])
  end

  def part2(args) do
    IO.puts("\n")

    args
    |> parse_input()
    |> Enum.reverse()
    |> fill_cycles()
    |> Enum.reverse()
    |> Enum.reverse()
    |> Map.new()
    |> draw()
    |> Enum.chunk_every(40)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def draw(cycles) do
    Enum.reduce(0..240, [], fn current_cycle, acc ->
      acc ++ draw_cycle(cycles, current_cycle)
    end)
  end

  def draw_cycle(cycles, current_cycle) do
    range =
      cycles
      |> Map.get(current_cycle + 1)
      |> valid_pixels()

    if rem(current_cycle, 40) in range do
      ["#"]
    else
      ["."]
    end
  end

  def valid_pixels(register_val), do: (register_val - 1)..(register_val + 1)

  def handle_instruction(["noop"], acc) do
    acc
    |> List.first()
    |> (fn {cycle, val} -> [{cycle + 1, val} | acc] end).()
  end

  def handle_instruction(["addx", amt], acc) do
    acc
    |> List.first()
    |> (fn {cycle, val} -> [{cycle + 2, val + Helpers.get_integer(amt)} | acc] end).()
  end

  def score(cycles, score_cycles) do
    score_cycles
    |> Enum.reduce(0, fn cycle_to_score, score -> score + score_cycle(cycle_to_score, cycles) end)
  end

  def score_cycle(cycle_to_score, cycles) do
    cycles
    |> Enum.filter(fn {cycle, _} -> cycle <= cycle_to_score end)
    |> Enum.at(-1)
    |> (fn {_, x} -> cycle_to_score * x end).()
  end

  def fill_cycles(cycles) do
    cycles
    |> Enum.reduce([], &fill/2)
  end

  def fill(cycle, []), do: [cycle]

  def fill({cycle, val}, [{h_cycle, _} | _] = acc) do
    fills = Enum.map((h_cycle - 1)..(cycle + 1), fn cycle_idx -> {cycle_idx, val} end)
    [{cycle, val}] ++ fills ++ acc
  end
end
