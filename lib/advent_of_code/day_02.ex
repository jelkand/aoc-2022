defmodule AdventOfCode.Day02 do
  # matchups are structured as:
  # matchups[their_move][desired_outcome]
  @matchups %{
    rock: %{
      win: :paper,
      lose: :scissors,
      draw: :rock
    },
    paper: %{
      win: :scissors,
      lose: :rock,
      draw: :paper
    },
    scissors: %{
      win: :rock,
      lose: :paper,
      draw: :scissors
    }
  }

  def parse_input(args) do
    args
    |> String.trim()
    |> String.split("\n")
  end

  def part1(args) do
    args
    |> parse_input()
    |> Enum.map(&move_to_tuple_p1/1)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.map(&move_to_tuple_p2/1)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  def move_to_tuple_p1(line) do
    line
    |> String.split(" ")
    |> Enum.map(&move_to_atom_p1/1)
  end

  def move_to_tuple_p2(line) do
    line
    |> String.split(" ")
    |> Enum.map(&move_to_atom_p2/1)
    |> to_moves()
  end

  def move_to_atom_p1(move) do
    case move do
      "A" -> :rock
      "X" -> :rock
      "B" -> :paper
      "Y" -> :paper
      "C" -> :scissors
      "Z" -> :scissors
    end
  end

  def move_to_atom_p2(move) do
    case move do
      "A" -> :rock
      "B" -> :paper
      "C" -> :scissors
      "X" -> :lose
      "Y" -> :draw
      "Z" -> :win
    end
  end

  def to_moves([opponent, outcome]) do
    [opponent, @matchups[opponent][outcome]]
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
