defmodule AdventOfCode.Day15 do
  # 506543 too high
  def part1(args) do
    args
    |> parse_input()
    |> hash_all()
    |> Enum.sum()
  end

  def part2(_args) do
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def hash_all(charlists) do
    Enum.map(charlists, &hash_charlist/1)
  end

  def hash_charlist(charlist) do
    hash_charlist_internal(charlist, 0)
  end

  def hash_charlist_internal([], value), do: value

  def hash_charlist_internal([first | rest], value) do
    next_value =
      ((value + first) * 17)
      |> rem(256)

    hash_charlist_internal(rest, next_value)
  end
end
