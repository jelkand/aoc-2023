defmodule AdventOfCode.Day06 do
  def part1(args) do
    args
    |> parse_input()
    |> count_winning_plays()
    |> Enum.reduce(1, &*/2)
  end

  def part2(_args) do
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ", trim: true) |> tl() |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  def count_winning_plays(races) do
    races
    |> Enum.map(fn {time, record} ->
      Enum.count(0..time, &(&1 * (time - &1) > record))
    end)
  end
end
