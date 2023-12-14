defmodule AdventOfCode.Day14 do
  def part1(args) do
    max_row = String.split(args, "\n", trim: true) |> length()

    args
    |> parse_input()
    |> tilt_north()
    |> score(max_row)
  end

  def part2(_args) do
  end

  def parse_input(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.with_index()
      |> Enum.reduce([], fn {line, row_num}, acc ->
        positions =
          Enum.with_index(line)
          |> Enum.map(fn {value, col_num} ->
            {{row_num, col_num}, value}
          end)
          |> Enum.filter(fn {_, v} -> v != "." end)

        positions ++ acc
      end)

    {rounds, squares} = Enum.split_with(map, fn {_, val} -> val == "O" end)

    {rounds |> Enum.map(&elem(&1, 0)), squares |> Enum.map(&elem(&1, 0))}
  end

  def get_input_dimensions(rows) do
    {length(rows), List.first(rows) |> String.length()}
  end

  def tilt_north({rounds, squares}) do
    # bucket together?

    rounds_by_col = Enum.group_by(rounds, &elem(&1, 1))
    squares_by_col = Enum.group_by(squares, &elem(&1, 1))

    bucketed_rounds =
      Enum.reduce(rounds_by_col, %{}, fn {col, rounds_in_col}, acc ->
        squares_in_col =
          [{-1, col} | Map.get(squares_by_col, col, [])]
          |> Enum.sort_by(&elem(&1, 0), :desc)

        get_rounds_by_chunk(rounds_in_col, squares_in_col, acc)
      end)

    unbucketed_rounds =
      Enum.reduce(bucketed_rounds, [], fn {square, bucket_rounds}, acc ->
        unbucketed = unbucket_rounds(bucket_rounds, square)

        unbucketed ++ acc
      end)

    {unbucketed_rounds, squares}
  end

  def get_rounds_by_chunk([], _, acc), do: acc

  def get_rounds_by_chunk(
        rounds_in_col,
        [{s_row, _} = square | rest_squares],
        acc
      ) do
    {rounds_after_square, rest_rounds} =
      Enum.split_with(rounds_in_col, fn {r_row, _r_col} -> r_row > s_row end)

    get_rounds_by_chunk(rest_rounds, rest_squares, Map.put(acc, square, rounds_after_square))
  end

  def unbucket_rounds([], _), do: []

  def unbucket_rounds(bucket_rounds, {s_row, s_col}) do
    for row_offset <- 1..length(bucket_rounds) do
      {s_row + row_offset, s_col}
    end
  end

  def score({rounds, _}, max_row) do
    rounds
    |> Enum.map(&(max_row - elem(&1, 0)))
    |> Enum.sum()
  end
end
