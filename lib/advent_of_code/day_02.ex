defmodule AdventOfCode.Day02 do
  score_map = %{
    rock: 1,
    paper: 2,
    scissors: 3,
    draw: 3,
    win: 6
  }

  # matchups = %{
  #   rock: %{
  #     rock: :draw,
  #     : :win,
  #   }
  # }
  def part1(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&move_to_tuple/1)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def part2(args) do
  end

  def move_to_tuple(line) do
    line
    |> String.split(" ")
    |> Enum.map(&move_to_atom/1)
  end

  def move_to_atom(move) do
    case move do
      "A" -> :rock
      "X" -> :rock
      "B" -> :paper
      "Y" -> :paper
      "C" -> :scissors
      "Z" -> :scissors
    end
  end

  def score([opponent_move, player_move]) do
    move_score =
      case player_move do
        :rock -> 1
        :paper -> 2
        :scissors -> 3
        _ -> 0
      end

    result_score =
      case {opponent_move, player_move} do
        {draw, draw} -> 3
        {:rock, :paper} -> 6
        {:paper, :scissors} -> 6
        {:scissors, :rock} -> 6
        _ -> 0
      end

    result_score + move_score
  end
end
