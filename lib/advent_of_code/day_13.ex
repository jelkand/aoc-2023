defmodule AdventOfCode.Day13 do
  # 31371 too low
  def part1(args) do
    args
    |> parse_input()
    |> Enum.map(&find_reflections_in_pattern/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.map(&find_reflections_in_pattern(&1, 1))
    |> Enum.sum()
  end

  def parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_pattern/1)
  end

  def parse_pattern(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def find_reflections_in_pattern(pattern, max_errors \\ 0) do
    vertical_size = length(pattern)
    horizontal_size = hd(pattern) |> length()

    horizontal_reflections = get_horizontal_reflections(pattern, vertical_size, max_errors)

    vertical_reflections =
      pattern |> transpose() |> get_horizontal_reflections(horizontal_size, max_errors)

    {vertical_reflections, horizontal_reflections}

    vertical_reflections + 100 * horizontal_reflections
  end

  def get_horizontal_reflections(pattern, pattern_size, max_errors \\ 0) do
    Enum.find(1..(pattern_size - 1), 0, fn mirror_point ->
      to_grab = min(mirror_point, pattern_size - mirror_point)

      left = Enum.slice(pattern, (mirror_point - to_grab)..(mirror_point - 1))
      right = Enum.slice(pattern, mirror_point..(mirror_point + to_grab - 1))

      # for part 1
      # Enum.reverse(left) == right

      Enum.reverse(left) |> count_errors(right) == max_errors
    end)
  end

  def count_errors([], []), do: 0

  def count_errors([left | lrest], [right | rrest]) do
    (Enum.zip(left, right) |> Enum.count(fn {l, r} -> l != r end)) +
      count_errors(lrest, rrest)
  end

  def transpose(matrix) do
    matrix
    |> Enum.at(0)
    |> Enum.with_index()
    |> Enum.map(fn {_, idx} ->
      Enum.map(matrix, fn row ->
        Enum.at(row, idx)
      end)
    end)
  end
end
