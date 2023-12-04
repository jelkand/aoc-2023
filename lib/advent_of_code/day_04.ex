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

    {MapSet.new(winners), MapSet.new(numbers)}
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

  def accumulate_scorecards(winners_list) do
    Enum.with_index(winners_list, 1)
    |> Enum.reduce(%{}, fn {count, index}, copies ->
      copies = Map.update(copies, index, 1, &(&1 + 1))
      current = Map.get(copies, index)

      case count do
        0 ->
          copies

        _ ->
          Enum.reduce(1..count, copies, fn offset, this_copies ->
            Map.update(this_copies, index + offset, current, fn existing ->
              existing + current
            end)
          end)
      end
    end)
  end

  def part1(args) do
    args
    |> parse_input()
    |> count_winners()
    |> score()
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> count_winners()
    |> accumulate_scorecards()
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end
end
