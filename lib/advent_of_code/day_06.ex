defmodule AdventOfCode.Day06 do
  def part1(args) do
    args
    |> parse_input()
    |> count_winning_plays()
    |> Enum.reduce(1, &*/2)
  end

  def part2(args) do
    args
    |> parse_input_2()
    |> count_winning_plays_in_race()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ", trim: true) |> tl() |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  def parse_input_2(input) do
    [time, record] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line |> String.split(" ", trim: true) |> tl() |> Enum.join("") |> String.to_integer()
      end)

    {time, record}
  end

  def count_winning_plays(races) do
    races
    |> Enum.map(fn race ->
      count_winning_plays_in_race(race)
    end)
  end

  def count_winning_plays_in_race({time, record}) do
    Enum.count(0..time, &(&1 * (time - &1) > record))
  end
end
