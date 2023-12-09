defmodule AdventOfCode.Day09 do
  def part1(args) do
    args |> parse_input() |> Enum.map(fn line -> handle_line(line, &+/2) end) |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.map(fn line -> handle_line(line, &-/2, :part_2) end)
    |> Enum.sum()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row -> String.split(row, " ", trim: true) |> Enum.map(&String.to_integer/1) end)
  end

  def get_differences(line) do
    line |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)
  end

  def is_zeros(line), do: Enum.all?(line, fn element -> element == 0 end)

  def handle_line(line, operator, flag \\ nil) do
    line |> reduce_line([]) |> maybe_reverse_all(flag) |> sum_lines(operator)
  end

  def reduce_line(line, acc) do
    case is_zeros(line) do
      true -> [line | acc]
      false -> reduce_line(get_differences(line), [line | acc])
    end
  end

  def maybe_reverse_all(lines, :part_2), do: lines
  def maybe_reverse_all(lines, _), do: Enum.map(lines, &Enum.reverse/1)

  def sum_lines([only], _), do: hd(only)

  def sum_lines([last, second_last | rest], operator) do
    to_add = operator.(hd(second_last), hd(last))

    sum_lines([[to_add | second_last] | rest], operator)
  end
end
