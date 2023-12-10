defmodule AdventOfCode.Day10 do
  def part1(args) do
    args
    |> parse_input()
    |> solve_1()
  end

  def part2(_args) do
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index()
    |> Enum.flat_map(&handle_line/1)
    |> Enum.into(%{})
  end

  def handle_line({value, row}) do
    value
    |> Enum.with_index()
    |> Enum.map(fn {symbol, col} ->
      {{row, col}, {symbol, get_neighbors(symbol, {row, col})}}
    end)
  end

  def get_neighbors("|", {row, col}), do: [{row - 1, col}, {row + 1, col}]
  def get_neighbors("-", {row, col}), do: [{row, col - 1}, {row, col + 1}]
  def get_neighbors("L", {row, col}), do: [{row - 1, col}, {row, col + 1}]
  def get_neighbors("J", {row, col}), do: [{row - 1, col}, {row, col - 1}]
  def get_neighbors("7", {row, col}), do: [{row + 1, col}, {row, col - 1}]
  def get_neighbors("F", {row, col}), do: [{row + 1, col}, {row, col + 1}]

  # def get_neighbors("S", {row, col}),
  #   do: MapSet.new([{row - 1, col}, {row + 1, col}, {row, col + 1}, {row, col - 1}])

  def get_neighbors(_, _), do: []

  def solve_1(map) do
    {start_position, _} = Enum.find(map, fn {_pos, {symbol, _}} -> symbol == "S" end)

    [left, right] =
      Enum.filter(map, fn {_, {_, neighbors}} -> start_position in neighbors end)

    next_position({left, start_position}, {right, start_position}, map, 1)
  end

  # no idea why but this isn't matching when it should
  # def next_position({{left_pos, _, _}, _}, {{right_pos, _, _}, _}, _, count)
  #     when left_pos == right_pos,
  #     do: count

  def next_position({{lpos, {_, _}}, _} = left, {{rpos, {_, _}}, _} = right, map, count) do
    case lpos == rpos do
      true ->
        count

      false ->
        next_position(get_next(left, map), get_next(right, map), map, count + 1)
    end
  end

  def get_next({{pos, {_, neighbors}}, came_from}, map) do
    next_pos = List.delete(neighbors, came_from) |> hd()
    next = Map.get(map, next_pos)
    {{next_pos, next}, pos}
  end
end
