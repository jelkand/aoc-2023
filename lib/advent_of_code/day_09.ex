defmodule AdventOfCode.Day09 do
  def part1(args) do
    args |> parse_input() |> Enum.map(&handle_line/1) |> Enum.sum()
  end

  def part2(_args) do
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

  def handle_line(line) do
    line |> reduce_line([]) |> reverse_all() |> sum_lines()
  end

  def reduce_line(line, acc) do
    case is_zeros(line) do
      true -> [line | acc]
      false -> reduce_line(get_differences(line), [line | acc])
    end
  end

  def reverse_all(lines), do: Enum.map(lines, &Enum.reverse/1)

  def sum_lines([only]), do: hd(only)

  def sum_lines([last, second_last | rest]) do
    to_add = hd(last) + hd(second_last)

    sum_lines([[to_add | second_last] | rest])
  end
end
