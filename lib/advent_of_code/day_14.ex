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
    # max_col = String.split(args, "\n", trim: true) |> hd() |> String.length()

    board = parse_input(args)

    {cycle_size, last_cycle_pos, last_cycle} =
      find_cycle(board)

    remainder_to_iterate = rem(1_000_000_000 - last_cycle_pos, cycle_size)

    last_cycle
    |> cycle_times(remainder_to_iterate + 1)
    # |> pretty_print(max_row, max_col)
    |> score(max_row)

    # pretty_print(last_cycle, max_row, max_col)

    # next = last_cycle |> cycle_times(cycle_size) |> pretty_print(max_row, max_col)

    # IO.inspect(last_cycle == next, label: "same?")
    # |> cycle()
    # |> Stream.iterate(&cycle/1)
    # |> Stream.take_while(fn resulting_board ->
    #   pretty_print(resulting_board, max_row, max_col)
    #   resulting_board != board
    # end)
    # |> Enum.to_list()

    # |> cycle()
    # |> cycle()
    # |> cycle()
    # |> pretty_print(max_row, max_col)

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
    {rounds_by_col, squares_by_col} = get_rounds_squares(board, direction)

    bucketed_rounds =
      Enum.reduce(rounds_by_col, %{}, fn {col, rounds_in_col}, acc ->
        squares_in_col = get_squares(squares_by_col, col, direction)

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

  def get_squares(squares, col, :south),
    do: Map.get(squares, col, []) |> Enum.sort_by(&elem(&1, 0), :asc)

  def get_squares(squares, col, :west),
    do: Map.get(squares, col, []) |> Enum.sort_by(&elem(&1, 1), :desc)

  def get_squares(squares, col, :east),
    do: Map.get(squares, col, []) |> Enum.sort_by(&elem(&1, 1), :asc)

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
  def split_with({r_row, _}, {s_row, _}, :south), do: r_row < s_row

  def split_with({_, r_col}, {_, s_col}, :west), do: r_col > s_col
  def split_with({_, r_col}, {_, s_col}, :east), do: r_col < s_col

  def unbucket_rounds([], _, _), do: []

  def unbucket_rounds(bucket_rounds, {s_row, s_col}, :north) do
    for row_offset <- 1..length(bucket_rounds) do
      {s_row + row_offset, s_col}
    end
  end

  def unbucket_rounds(bucket_rounds, {s_row, s_col}, :south) do
    for row_offset <- 1..length(bucket_rounds) do
      {s_row - row_offset, s_col}
    end
  end

  def unbucket_rounds(bucket_rounds, {s_row, s_col}, :west) do
    for col_offset <- 1..length(bucket_rounds) do
      {s_row, s_col + col_offset}
    end
  end

  def unbucket_rounds(bucket_rounds, {s_row, s_col}, :east) do
    for col_offset <- 1..length(bucket_rounds) do
      {s_row, s_col - col_offset}
    end
  end

  def score({rounds, _}, max_row) do
    rounds
    # add one to offset the line of padding at the bottom
    |> Enum.map(&(max_row + 1 - elem(&1, 0)))
    |> Enum.sum()
  end

  def cycle(board) do
    board
    |> tilt(:north)
    |> tilt(:west)
    |> tilt(:south)
    |> tilt(:east)
  end

  def cycle_times(board, times) do
    Stream.iterate(board, &cycle/1)
    |> Enum.at(times)
  end

  def find_cycle(board) do
    board
    |> find_cycle_internal([:erlang.phash2(board)])
  end

  # {cycle_size, last_cycle_pos, last_cycle} =
  #   find_cycle(board)

  def find_cycle_internal(board, found_boards) do
    next = cycle(board)

    hashed = :erlang.phash2(next)

    case Enum.find_index(found_boards, fn e -> e == hashed end) do
      nil ->
        find_cycle_internal(next, [hashed | found_boards])

      found_at ->
        num_cycles =
          length(found_boards)

        {found_at + 1, num_cycles + 1, next}
    end
  end

  def pretty_print({rounds, squares}, max_row, max_col) do
    rset = MapSet.new(rounds)
    sset = MapSet.new(squares)

    for row <- 1..max_row do
      IO.write("\n")

      for col <- 1..max_col do
        cond do
          {row, col} in rset -> IO.write("O")
          {row, col} in sset -> IO.write("#")
          true -> IO.write(".")
        end
      end
    end

    IO.write("\n")
    {rounds, squares}
  end
end
