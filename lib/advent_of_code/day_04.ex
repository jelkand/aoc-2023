defmodule AdventOfCode.Day04 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [winners, numbers] =
      line
      |> String.split(": ", trim: true)
      |> List.last()
      |> String.split(" | ", trim: true)
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))

    number_set = MapSet.new(numbers)

    if MapSet.size(number_set) != length(numbers),
      do: IO.puts("Got set of numbers with duplicates")

    {MapSet.new(winners), number_set}
  end

  def count_winners(lines) do
    Enum.map(lines, fn {winners, numbers} ->
      MapSet.intersection(winners, numbers) |> MapSet.size()
    end)
  end

  def score(matches) do
    matches
    |> Enum.filter(fn count -> count > 0 end)
    |> Enum.map(fn count -> 2 ** (count - 1) end)
  end

  def part1(args) do
    args
    |> parse_input()
    |> count_winners()
    |> score()
    |> Enum.sum()
  end

  def part2(_args) do
  end
end
