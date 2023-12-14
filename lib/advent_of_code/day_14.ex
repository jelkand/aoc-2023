defmodule AdventOfCode.Day14 do
  def part1(args) do
    max_row = String.split(args, "\n", trim: true) |> length()

    args
    |> parse_input()
    |> tilt(:north)
    |> score(max_row)
  end

  def part2(args) do
    max_row = String.split(args, "\n", trim: true) |> length()

    args
    |> parse_input()
    |> tilt(:north)
    |> tilt(:west)
    |> tilt(:south)
    |> tilt(:east)
    |> dbg()

    # |> score(max_row)
  end

  def parse_input(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
      |> pad_input()
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

  # surrounds the input with a boundary of squares to simplify the calc
  def pad_input(rows) do
    size = rows |> hd() |> length()
    top_bottom = List.duplicate("#", size + 2)

    middle =
      Enum.map(rows, fn row ->
        ["#"] ++ row ++ ["#"]
      end)

    [top_bottom] ++ middle ++ [top_bottom]
  end

  def get_input_dimensions(rows) do
    {length(rows), List.first(rows) |> String.length()}
  end

  def tilt({_, squares} = board, direction) do
    # bucket together?
    {rounds_by_col, squares_by_col} = get_rounds_squares(board, direction)

    bucketed_rounds =
      Enum.reduce(rounds_by_col, %{}, fn {col, rounds_in_col}, acc ->
        squares_in_col = get_squares(squares_by_col, col, direction)
        # squares_in_col =
        #   Map.get(squares, col, [])
        #   |> Enum.sort_by(&elem(&1, 0), :desc)

        get_rounds_by_chunk(rounds_in_col, squares_in_col, acc, direction)
      end)

    unbucketed_rounds =
      Enum.reduce(bucketed_rounds, [], fn {square, bucket_rounds}, acc ->
        unbucketed = unbucket_rounds(bucket_rounds, square, direction)

        unbucketed ++ acc
      end)

    {unbucketed_rounds, squares}
  end

  def get_rounds_squares({rounds, squares}, direction)
      when direction == :north
      when direction == :south do
    rounds_by_col = Enum.group_by(rounds, &elem(&1, 1))
    squares_by_col = Enum.group_by(squares, &elem(&1, 1))

    {rounds_by_col, squares_by_col}
  end

  def get_rounds_squares({rounds, squares}, direction)
      when direction == :east
      when direction == :west do
    rounds_by_row = Enum.group_by(rounds, &elem(&1, 0))
    squares_by_row = Enum.group_by(squares, &elem(&1, 0))

    {rounds_by_row, squares_by_row}
  end

  def get_squares(squares, col, :north),
    do: Map.get(squares, col, []) |> Enum.sort_by(&elem(&1, 0), :desc)

  def get_rounds_by_chunk([], _, acc, _), do: acc

  def get_rounds_by_chunk(
        rounds_in_col,
        [square | rest_squares],
        acc,
        direction
      ) do
    {rounds_after_square, rest_rounds} =
      Enum.split_with(rounds_in_col, &split_with(&1, square, direction))

    get_rounds_by_chunk(
      rest_rounds,
      rest_squares,
      Map.put(acc, square, rounds_after_square),
      direction
    )
  end

  def split_with({r_row, _}, {s_row, _}, :north), do: r_row > s_row

  def unbucket_rounds([], _, _), do: []

  def unbucket_rounds(bucket_rounds, {s_row, s_col}, direction) do
    for row_offset <- unbucket_range(bucket_rounds, direction) do
      {s_row + row_offset, s_col}
    end
  end

  def unbucket_range(bucketed, :north), do: 1..length(bucketed)

  def score({rounds, _}, max_row) do
    rounds
    # add one to offset the line of padding at the bottom
    |> Enum.map(&(max_row + 1 - elem(&1, 0)))
    |> Enum.sum()
  end
end
