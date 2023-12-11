defmodule AdventOfCode.Day11 do
  def part1(args) do
    args
    |> parse_input()
    |> get_distances()
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(args, multiplier \\ 1_000_000) do
    args
    |> parse_input()
    |> get_distances(multiplier)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def parse_input(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.with_index()
      |> Enum.flat_map(&handle_line/1)

    max_rows = Enum.max_by(map, fn {{r, _}, _} -> r end) |> elem(0) |> elem(0)
    max_cols = Enum.max_by(map, fn {{_, c}, _} -> c end) |> elem(0) |> elem(1)

    empty_rows =
      Enum.reduce(0..(max_rows - 1), [], fn row, acc ->
        has_galaxy? =
          Enum.filter(map, fn {{r, _}, _} -> r == row end)
          |> Enum.any?(fn {_, sym} -> sym == "#" end)

        if !has_galaxy?, do: [row | acc], else: acc
      end)

    empty_cols =
      Enum.reduce(0..(max_cols - 1), [], fn col, acc ->
        has_galaxy? =
          Enum.filter(map, fn {{_, c}, _} -> c == col end)
          |> Enum.any?(fn {_, sym} -> sym == "#" end)

        if !has_galaxy?, do: [col | acc], else: acc
      end)

    galaxies =
      map
      |> Enum.filter(fn {_pos, sym} -> sym == "#" end)

    {empty_rows, empty_cols, galaxies}
  end

  def handle_line({value, row}) do
    value
    |> Enum.with_index()
    |> Enum.map(fn {symbol, col} ->
      {{row, col}, symbol}
    end)
  end

  def get_distances({empty_rows, empty_cols, galaxies}, multiplier \\ 2) do
    for {g1, _sym} <- galaxies, {g2, _sym} <- galaxies, g1 != g2, into: %{} do
      [{first_r, first_c} = first, {second_r, second_c} = second] = Enum.sort([g1, g2])

      distance = abs(first_r - second_r) + abs(first_c - second_c)

      empty_rows_in_range =
        Enum.count(empty_rows, fn row_idx -> row_idx in first_r..second_r end)

      empty_cols_in_range =
        Enum.count(empty_cols, fn col_idx -> col_idx in first_c..second_c end)

      distance =
        distance + (empty_rows_in_range + empty_cols_in_range) * (multiplier - 1)

      {{first, second}, distance}
    end
  end
end
