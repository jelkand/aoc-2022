defmodule AdventOfCode.Day13 do
  def compare({first, second}) when is_integer(first) and is_integer(second),
    do: first - second

  def compare({first, second}) when is_integer(first) and is_list(second),
    do: compare({[first], second})

  def compare({first, second}) when is_list(first) and is_integer(second),
    do: compare({first, [second]})

  def compare({[], second}) when is_list(second), do: -1
  def compare({first, []}) when is_list(first), do: 1

  def compare({[first_head | first_rest], [second_head | second_rest]}) do
    case compare({first_head, second_head}) do
      diff when diff == 0 ->
        compare({first_rest, second_rest})

      diff when diff < 0 ->
        diff

      diff ->
        diff
    end
  end

  def parse_strings(pair_str) do
    String.split(pair_str, "\n", trim: true)
    |> Enum.map(fn str -> Code.eval_string(str) |> Kernel.elem(0) end)
    |> List.to_tuple()
  end

  def part1(args) do
    String.split(args, "\n\n", trim: true)
    |> tap(fn list -> IO.inspect(length(list), label: "pairs: ") end)
    |> Enum.map(&parse_strings/1)
    |> Enum.map(&compare/1)
    |> Enum.with_index(1)
    |> Enum.filter(&(Kernel.elem(&1, 0) < 0))
    |> IO.inspect(label: "diffs")
    |> Enum.map(&Kernel.elem(&1, 1))
    |> Enum.sum()
  end

  def part2(args) do
  end
end
