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

  def solve(path, score, _, _, 0), do: score

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
        score

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
    # |> IO.inspect(label: "Unfiltered map for #{node} with #{time_remaining} time remaining")
    |> Enum.filter(fn {_, _, score} -> score > 0 end)
  end

  # def solve_left(
  #       [lh | _] = left,
  #       right,
  #       score,
  #       adj_list,
  #       pressure_map,
  #       l_time_remaining,
  #       r_time_remaining
  #     ) do
  #   if Enum.max_by(pressure_map, fn {_k, v} -> v end) |> elem(1) == 0 do
  #     IO.inspect({score, left, right}, label: "final score for l, r")
  #     score
  #   else
  #     [{lnode, ldist, lscore} | _] =
  #       build_scoring_map(adj_list, pressure_map, lh, l_time_remaining)
  #       |> IO.inspect(label: "L scoring map for #{l_time_remaining} time remaining")
  #   end
  # end

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
    if Enum.max_by(pressure_map, fn {_k, v} -> v end) |> elem(1) == 0 do
      IO.inspect({score, left, right, pressure_map}, label: "final score for l, r")
      score
    else
      IO.inspect(
        {left, right, Enum.filter(pressure_map, fn {_, v} -> v > 0 end) |> Map.new(),
         l_time_remaining, r_time_remaining, score},
        label: "lh,rh"
      )

      pressure_set =
        Enum.filter(pressure_map, fn {_, v} -> v > 0 end)
        |> Map.new()
        |> Map.keys()
        |> MapSet.new()

      Helpers.djikstras(adj_list, rh)
      |> Enum.filter(fn {k, _v} ->
        k in pressure_set
      end)
      |> IO.inspect(label: "right valve distances from #{rh}")

      left_scoring_map = build_scoring_map(adj_list, pressure_map, lh, l_time_remaining)
      # |> IO.inspect(label: "L scoring map for #{l_time_remaining} time remaining")

      right_scoring_map =
        build_scoring_map(adj_list, pressure_map, rh, r_time_remaining)
        |> IO.inspect(label: "R scoring map for #{r_time_remaining} time remaining")

      {{lnode, ldist, lscore}, {rnode, rdist, rscore}} =
        get_targets(left_scoring_map, right_scoring_map)

      # new_pressure_map = Map.put(pressure_map, lnode, 0) |> Map.put(rnode, 0)

      # |> IO.inspect(label: "ltime")
      l_time = l_time_remaining - ldist - 1
      # |> IO.inspect(label: "rtime")
      r_time = r_time_remaining - rdist - 1

      # cond do
      #   rnode == nil and lnode == nil ->
      #     score

      # lnode == nil ->
      #   solve([rnode | right], score + rscore, adj_list, pressure_map, r_time_remaining)

      # rnode == nil ->
      #   solve([lnode | left], score + lscore, adj_list, pressure_map, l_time_remaining)

      #   true ->
      #     solve_pair(
      #       [lnode | left] |> Enum.filter(fn val -> val != nil end),
      #       [rnode | right] |> Enum.filter(fn val -> val != nil end),
      #       score + lscore + rscore,
      #       adj_list,
      #       Map.put(pressure_map, lnode, 0) |> Map.put(rnode, 0),
      #       l_time,
      #       r_time
      #     )
      # end

      case {l_time, r_time, left_scoring_map, right_scoring_map} do
        {_, _, [], []} ->
          score

        {ltime, rtime, _, _} when ltime - rtime > 0 ->
          # IO.inspect(lnode, label: "sending to left:")

          solve_pair(
            [lnode | left] |> Enum.filter(fn val -> val != nil end),
            right,
            score + lscore,
            adj_list,
            Map.put(pressure_map, lnode, 0),
            l_time,
            r_time_remaining
          )

        {ltime, rtime, _, _} when ltime == rtime ->
          # IO.inspect(l_time - r_time, label: "doing a pair")

          solve_pair(
            [lnode | left] |> Enum.filter(fn val -> val != nil end),
            [rnode | right] |> Enum.filter(fn val -> val != nil end),
            score + lscore + rscore,
            adj_list,
            Map.put(pressure_map, lnode, 0) |> Map.put(rnode, 0),
            l_time,
            r_time
          )

        {ltime, rtime, _, _} when ltime - rtime < 0 ->
          # IO.inspect(rnode, label: "sending to right:")

          solve_pair(
            left,
            [rnode | right] |> Enum.filter(fn val -> val != nil end),
            score + rscore,
            adj_list,
            Map.put(pressure_map, rnode, 0),
            l_time_remaining,
            r_time
          )
      end
    end
  end

  def get_targets([], []) do
    {{nil, 0, 0}, {nil, 0, 0}}
  end

  def get_targets([], [right | _]) do
    {{nil, 0, 0}, right}
  end

  def get_targets([left | _], []) do
    {left, {nil, 0, 0}}
  end

  def get_targets([{lnode, ldist, lscore} | _], [
        {rnode, _, rscore},
        {rnext, rdist, rnext_score} | _
      ])
      when lnode == rnode and lscore > rscore do
    {{lnode, ldist, lscore}, {rnext, rdist, rnext_score}}
  end

  def get_targets([{lnode, _, lscore}, {lnext, ldist, lnext_score} | _], [
        {rnode, rdist, rscore},
        {_, _, rnext_score} | _
      ])
      when lnode == rnode and lscore == rscore and lnext_score >= rnext_score do
    {{lnext, ldist, lnext_score}, {rnode, rdist, rscore}}
  end

  def get_targets([{lnode, ldist, lscore} | _], [
        {rnode, _, rscore},
        {rnext, rdist, rnext_score} | _
      ])
      when lnode == rnode and lscore == rscore do
    {{lnode, ldist, lscore}, {rnext, rdist, rnext_score}}
  end

  def get_targets([{lnode, _, _}, {lnext, ldist, lnext_score} | _], [{rnode, rdist, rscore} | _])
      when lnode == rnode do
    {{lnext, ldist, lnext_score}, {rnode, rdist, rscore}}
  end

  def get_targets([{lnode, ldist, lscore} | _], [{rnode, rdist, rscore} | _]),
    do: {{lnode, ldist, lscore}, {rnode, rdist, rscore}}

  def part1(args) do
    [pressure_map, adj_list] = parse_input(args)

    solve(["AA"], 0, adj_list, pressure_map, 30)
    |> List.flatten()
    |> Enum.max()

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

  def part2(args) do
    [pressure_map, adj_list] = parse_input(args)
    # [valve | non_starting_valves] = Map.keys(pressure_map) |> IO.inspect(label: "keys")

    solve_pair(["AA"], ["AA"], 0, adj_list, pressure_map, 26, 26) |> IO.inspect()
  end
end
