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

  def solve(path, score, _, _, 0), do: {path, score}

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
        # |> IO.inspect(label: "finished with #{time_remaining} time remaining:")
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

  def build_scoring_map(adj_list, pressure_map, node, time_remaining) do
    Helpers.djikstras(adj_list, node)
    |> Enum.map(fn {k, dist} ->
      # calculate time remaining when you get there, and multiply by flow
      # to see how much it's worth if we head to it now.
      {k, dist, (time_remaining - dist - 1) * pressure_map[k]}
    end)
    |> Enum.sort_by(fn {_valve, _dist, score} -> score end, :desc)
    |> Enum.filter(fn {_, _, score} -> score > 0 end)
  end

  def solve_pair(_, _, score, _, _, 0, 0), do: score |> IO.inspect(label: "bailing both zero")

  def solve_pair(
        [lh | _] = left,
        [rh | _] = right,
        score,
        adj_list,
        pressure_map,
        l_time_remaining,
        r_time_remaining
      ) do
    cond do
      Enum.max_by(pressure_map, fn {_k, v} -> v end) |> elem(1) == 0 ->
        score

      true ->
        left_scoring_map = build_scoring_map(adj_list, pressure_map, lh, l_time_remaining)

        right_scoring_map = build_scoring_map(adj_list, pressure_map, rh, r_time_remaining)

        pairs =
          Helpers.pairs_of(left_scoring_map, right_scoring_map)
          |> Enum.filter(&filter_pairs/1)

        # |> IO.inspect(label: "pairs")

        case {left_scoring_map, right_scoring_map, pairs} do
          {[], [], _} ->
            score

          {_, _, []} ->
            score

          _ ->
            IO.inspect(pairs, label: "recursing for pairs:")

            Enum.map(pairs, fn {l, r} ->
              solve_inner(
                left,
                right,
                score,
                adj_list,
                pressure_map,
                l_time_remaining,
                r_time_remaining,
                {l, r}
              )
            end)
        end
    end
  end

  def solve_inner(
        left,
        right,
        score,
        adj_list,
        pressure_map,
        l_time_remaining,
        r_time_remaining,
        {nil, {rnode, rdist, rscore}}
      ) do
    solve_pair(
      left,
      [rnode | right],
      score + rscore,
      adj_list,
      Map.put(pressure_map, rnode, 0),
      l_time_remaining - 1,
      r_time_remaining - rdist - 1
    )
  end

  def solve_inner(
        left,
        right,
        score,
        adj_list,
        pressure_map,
        l_time_remaining,
        r_time_remaining,
        {{lnode, ldist, lscore}, nil}
      ) do
    solve_pair(
      [lnode | left],
      right,
      score + lscore,
      adj_list,
      Map.put(pressure_map, lnode, 0),
      l_time_remaining - ldist - 1,
      r_time_remaining - 1
    )
  end

  def solve_inner(
        left,
        right,
        score,
        adj_list,
        pressure_map,
        l_time_remaining,
        r_time_remaining,
        {{lnode, ldist, lscore}, {rnode, rdist, rscore}}
      ) do
    solve_pair(
      [lnode | left],
      [rnode | right],
      score + lscore + rscore,
      adj_list,
      Map.put(pressure_map, lnode, 0) |> Map.put(rnode, 0),
      l_time_remaining - ldist - 1,
      r_time_remaining - rdist - 1
    )
  end

  def filter_pairs({nil, _}), do: true
  def filter_pairs({_, nil}), do: true
  def filter_pairs({l, r}), do: elem(l, 0) !== elem(r, 0)

  def part1(args) do
    [pressure_map, adj_list] = parse_input(args)

    solve(["AA"], 0, adj_list, pressure_map, 30)
    |> List.flatten()
    |> Enum.map(&elem(&1, 1))
    |> Enum.max()
    |> IO.inspect(label: "part 1")

    # |> Enum.sort_by(fn score -> score end, :desc)
    # |> List.first()

    # |> elem(1)
  end

  # def get_score(head, next, adj_list, pressure_map, time_remaining) do
  #   distance = Helpers.djikstras(adj_list, head, next) |> Map.get(next)
  #   (time_remaining - distance - 1) * pressure_map[next]
  # end

  def score_path(_, score, _, _, 0), do: score

  def score_path([singleton], score, _, pressure_map, time_remaining),
    do: score + time_remaining * pressure_map[singleton]

  def score_path([second_last, last | []], score, adj_list, pressure_map, time_remaining) do
    distance = Helpers.djikstras(adj_list, second_last, last) |> Map.get(last)

    score + (time_remaining - distance - 1) * pressure_map[last]
  end

  def score_path([head, next | rest], score, adj_list, pressure_map, time_remaining) do
    # IO.puts("scoring")
    distance = Helpers.djikstras(adj_list, head, next) |> Map.get(next)
    next_score = (time_remaining - distance - 1) * pressure_map[next]

    score_path(
      [next | rest],
      score + next_score,
      adj_list,
      Map.put(pressure_map, next, 0),
      time_remaining - distance - 1
    )
  end

  def part2_rejected(args) do
    [pressure_map, adj_list] = parse_input(args)

    keys =
      Map.keys(pressure_map)
      |> Enum.filter(fn node -> pressure_map[node] > 0 end)

    IO.inspect(length(keys), label: "keys")

    permutations_of_valves =
      keys
      |> Helpers.permute_list()

    IO.inspect(length(permutations_of_valves), label: "total permutations")

    # |> IO.inspect(label: "permutations")
    Enum.flat_map(1..(length(keys) - 1), fn idx ->
      Enum.map(permutations_of_valves, fn perm -> Enum.split(perm, idx) end)
      # Enum.split(permutations_of_valves, idx)
    end)
    |> tap(&IO.inspect(length(&1), label: "permutations/partitions to check"))
    |> Enum.map(fn {l, r} ->
      {score_path(["AA" | l], 0, adj_list, pressure_map, 26),
       score_path(["AA" | r], 0, adj_list, pressure_map, 26)}
    end)
    |> Enum.map(fn {a, b} -> a + b end)
    |> Enum.max()
  end

  def other_part2(args) do
    [pressure_map, adj_list] = parse_input(args)

    {me_path, me_score} =
      solve(["AA"], 0, adj_list, pressure_map, 26)
      |> List.flatten()
      |> Enum.max_by(fn {_path, score} -> score end)
      |> IO.inspect(label: "me")

    updated_pressures = Enum.reduce(me_path, pressure_map, fn k, acc -> Map.put(acc, k, 0) end)

    {ele_path, ele_score} =
      solve(["AA"], 0, adj_list, updated_pressures, 26)
      |> List.flatten()
      |> Enum.max_by(fn {_path, score} -> score end)
      |> IO.inspect(label: "elephant")

    Enum.reduce(ele_path, updated_pressures, fn k, acc -> Map.put(acc, k, 0) end)
    |> Enum.filter(fn {_, v} -> v > 0 end)
    |> IO.inspect(label: "unopened")

    me_score + ele_score
  end

  def part2(args) do
    [pressure_map, adj_list] = parse_input(args)
    # [valve | non_starting_valves] = Map.keys(pressure_map) |> IO.inspect(label: "keys")

    solve_pair(["AA"], ["AA"], 0, adj_list, pressure_map, 26, 26)
    |> List.flatten()
    |> Enum.max()
    |> IO.inspect()
  end
end
