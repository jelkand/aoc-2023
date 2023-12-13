defmodule AdventOfCode.Day13 do
  # 31371 too low
  def part1(args) do
    args
    |> parse_input()
    |> Enum.map(&find_reflections_in_pattern/1)
    |> Enum.sum()
  end

  def part2(_args) do
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

  def find_reflections_in_pattern(pattern) do
    vertical_size = length(pattern)
    horizontal_size = hd(pattern) |> length()

    horizontal_reflections = get_horizontal_reflections(pattern, vertical_size)

    vertical_reflections =
      pattern |> transpose() |> get_horizontal_reflections(horizontal_size)

    # {pattern, transpose(pattern)} |> dbg()

    # dbg(binding())
    # {horizontal_reflections, vertical_reflections} |> dbg()
    vertical_reflections + 100 * horizontal_reflections
  end

  def get_horizontal_reflections(pattern, pattern_size) do
    Enum.find(1..(pattern_size - 1), 0, fn mirror_point ->
      to_grab = min(mirror_point, pattern_size - mirror_point)

      left = Enum.slice(pattern, (mirror_point - to_grab)..(mirror_point - 1))
      right = Enum.slice(pattern, mirror_point..(mirror_point + to_grab))

      # dbg()

      Enum.reverse(left) == right
    end)
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
