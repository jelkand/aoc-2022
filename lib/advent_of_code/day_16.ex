defmodule AdventOfCode.Day16 do
  alias AdventOfCode.Helpers

  def parse_valve(valve_str) do
    [valve_def, neighbors_def] = String.split(valve_str, ";")
    [_, name, _, _, _, flow_rate_str] = String.split(valve_def, [" ", "="])

    neighbors =
      String.replace(neighbors_def, ~r" tunnels? leads? to valves? ", "")
      |> String.split(", ")

    {{name, Helpers.get_integer(flow_rate_str)}, {name, neighbors}}
  end

  def parse_input(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&parse_valve/1)
    |> Enum.reduce({[], []}, fn {value, neighbor}, {values, adj} ->
      {[value | values], [neighbor | adj]}
    end)
    |> Tuple.to_list()
    |> Enum.map(&Enum.into(&1, %{}))
  end

  def solve(path, score, _, _, 0), do: {path, score} |> IO.inspect(label: "zero time")

  def solve([head | _] = path, score, adj_list, pressure_map, time_remaining) do
    [{_, _, highest_score} | _] =
      scoring_map =
      Helpers.djikstras(adj_list, head)
      |> Enum.map(fn {k, dist} ->
        # calculate time remaining when you get there, and multiply by flow
        # to see how much it's worth if we head to it now.
        {k, dist, (time_remaining - dist - 1) * pressure_map[k]}
      end)
      |> Enum.sort_by(fn {_valve, _dist, score} -> score end, :desc)

    case highest_score > 0 do
      false ->
        {path, score}

      true ->
        Enum.filter(scoring_map, fn {_, _, score} -> score > 0 end)
        |> Enum.map(fn {next_valve, next_dist, next_score} ->
          solve(
            [next_valve | path],
            score + next_score,
            adj_list,
            Map.put(pressure_map, next_valve, 0),
            time_remaining - next_dist - 1
          )
        end)
    end
  end

  def part1(args) do
    [pressure_map, adj_list] = parse_input(args)

    solve(["AA"], 0, adj_list, pressure_map, 30)
    |> List.flatten()
    |> Enum.sort_by(fn {_path, score} -> score end, :desc)
    |> List.first()
    |> elem(1)
  end

  def part2(args) do
    IO.inspect(args, label: "part 2")
  end
end
