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
      # current = Map.get(copies, index, 1)
      copies = Map.update(copies, index, 1, &(&1 + 1))
      IO.puts("Adding one original to ")
      current = Map.get(copies, index)
      IO.puts("\n")

      IO.puts("Card #{index} has #{count} winning numbers. You have #{current} copies already.")

      IO.puts(
        "You win #{current} copies of the " <>
          (Range.to_list((index + 1)..(index + count))
           |> Enum.map(&"#{&1}")
           |> Enum.join(", ")) <> " scorecards"
      )

      case count do
        0 ->
          copies

        _ ->
          Enum.reduce(1..count, copies, fn offset, this_copies ->
            Map.update(this_copies, index + offset, current, fn existing ->
              IO.puts(
                "Adding #{current} copies of #{index + offset}, you had #{existing}, now you have #{current + existing}"
              )

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

  # 8305895 too low

  def part2(args) do
    IO.puts("\n\n\n\n")

    # args
    # |> parse_input()
    # |> count_winners()
    # |> Enum.with_index(1)
    # |> IO.inspect(label: "copies", limit: :infinity)

    # |> Enum.reverse()
    # |> Enum.filter(fn {val, _idx} -> val == 0 end)
    # |> Enum.map(&elem(&1, 1))
    # |> IO.inspect(label: "no winners")

    args
    |> parse_input()
    |> count_winners()
    |> accumulate_scorecards()
    |> Map.to_list()
    |> Enum.sort(fn {k1, _v}, {k2, _v2} -> k1 <= k2 end)
    |> IO.inspect(label: "copies", limit: :infinity)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
    |> IO.inspect(label: "total")
  end
end
