defmodule AdventOfCode.Day03 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def get_symbol_positions(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, row}, acc ->
      Enum.with_index(line)
      |> Enum.map(fn {value, col} -> {row, col, value} end)
      |> Enum.filter(fn {_row, _col, value} -> not Regex.match?(~r/\.|\d/, value) end)
      |> Enum.map(fn {r, c, _} -> {r, c} end)
      |> MapSet.new()
      |> MapSet.union(acc)
    end)
  end

  def get_gear_positions(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, row}, acc ->
      gears =
        Enum.with_index(line)
        |> Enum.map(fn {value, col} -> {row, col, value} end)
        |> Enum.filter(fn {_row, _col, value} -> Regex.match?(~r/\*/, value) end)

      update_acc(gears, acc)
    end)
    |> List.flatten()
  end

  def lines_with_positions(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, row} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {value, col} -> {row, col, value} end)
    end)
  end

  def lines_to_part_numbers(lines) do
    lines
    |> Enum.flat_map(&process_line/1)
  end

  def filter_part_numbers(part_numbers, symbol_positions) do
    part_numbers
    |> Enum.filter(fn %{neighbors: neighbors} ->
      MapSet.intersection(neighbors, symbol_positions) !== MapSet.new([])
    end)
    |> Enum.map(&Map.get(&1, :value))
  end

  def process_line(line) do
    line
    |> split_line_internal([])
    |> reduce_numbers()
  end

  defp split_line_internal([], acc), do: Enum.reverse(acc)

  defp split_line_internal(line, acc) do
    {num_list, rest} =
      Enum.split_while(line, fn {_row, _col, value} -> Regex.match?(~r/\d/, value) end)

    split_line_internal(get_rest(rest), update_acc(num_list, acc))
  end

  def get_rest([]), do: []
  def get_rest(list), do: tl(list)

  def update_acc([], acc), do: acc
  def update_acc(new, acc), do: [new | acc]

  def reduce_numbers(line) do
    line
    |> Enum.map(fn line ->
      line
      |> Enum.reduce(%{value: "", neighbors: MapSet.new()}, fn {row, col, value}, acc ->
        %{
          value: acc.value <> value,
          neighbors: MapSet.union(acc.neighbors, get_all_neighbors(row, col))
        }
      end)
      |> Map.update!(:value, &String.to_integer/1)
    end)
  end

  def get_all_neighbors(row, col) do
    for row_offset <- -1..1,
        col_offset <- -1..1 do
      {row + row_offset, col + col_offset}
    end
    |> Enum.into(MapSet.new())
  end

  def part1(args) do
    lines = parse_input(args)

    symbol_positions = get_symbol_positions(lines)

    lines
    |> lines_with_positions()
    |> lines_to_part_numbers()
    |> filter_part_numbers(symbol_positions)
    |> Enum.sum()
  end

  def part2(args) do
    lines = parse_input(args)

    gears = get_gear_positions(lines)

    part_numbers = lines |> lines_with_positions() |> lines_to_part_numbers()

    gears
    |> Enum.map(fn {row, col, _sym} ->
      neighbors =
        Enum.filter(part_numbers, fn %{neighbors: neighbors} ->
          MapSet.member?(neighbors, {row, col})
        end)

      Enum.map(neighbors, &Map.get(&1, :value))
    end)
    |> Enum.filter(&(length(&1) > 1))
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
  end
end
