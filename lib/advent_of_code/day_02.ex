defmodule AdventOfCode.Day02 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_game/1)
  end

  def parse_game(line) do
    [game | rounds] = String.split(line, ": ")
    game = String.split(game, " ") |> List.last() |> String.to_integer()
    rounds = parse_rounds(rounds)
    {game, rounds}
  end

  def parse_rounds(rounds) do
    rounds
    |> List.first()
    |> String.split("; ", trim: true)
    |> Enum.map(&parse_round/1)
  end

  def parse_round(round) do
    round
    |> String.split(", ", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce(%{}, &parse_pull/2)
  end

  def parse_pull([num, "red"], acc), do: Map.put(acc, :red, String.to_integer(num))
  def parse_pull([num, "blue"], acc), do: Map.put(acc, :blue, String.to_integer(num))
  def parse_pull([num, "green"], acc), do: Map.put(acc, :green, String.to_integer(num))

  def solve_1(games) do
    games
    |> get_max_colors()
    |> filter_by_cube_count(%{red: 12, green: 13, blue: 14})
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def get_max_colors(games) do
    games
    |> Enum.map(&max_rounds/1)
  end

  def max_rounds({game, rounds}) do
    {game,
     rounds
     |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _k, v1, v2 -> max(v1, v2) end))}
  end

  def filter_by_cube_count(games, filter) do
    games
    |> Enum.filter(fn {_game, max_pulled} ->
      Enum.all?(max_pulled, fn {color, amount} -> amount <= filter[color] end)
    end)
  end

  def get_game_power({_game, max_pulled}) do
    Enum.reduce(max_pulled, 1, fn {_color, amount}, acc -> acc * amount end)
  end

  def solve_2(games) do
    games
    |> get_max_colors()
    |> Enum.map(&get_game_power/1)
    |> Enum.sum()
  end

  def part1(args) do
    args
    |> parse_input()
    |> solve_1()
  end

  def part2(args) do
    args
    |> parse_input()
    |> solve_2()
  end
end
