defmodule AdventOfCode.Day16 do
  def part1(args) do
    args
    |> parse_input()
    |> trace_beam_and_count()
  end

  def part2(args) do
    map = parse_input(args)

    {rows, cols} = Enum.max_by(map, fn {pos, _} -> pos end) |> elem(0)

    construct_starts(rows, cols) |> run_all(map)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, row}, acc ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {sym, col}, inner_acc ->
        Map.put(inner_acc, {row, col}, sym)
      end)
    end)
  end

  def trace_beam_and_count(map, start \\ {0, 0, :right}) do
    trace_beam_internal(map, [start], MapSet.new())
    |> count_energized()
  end

  def trace_beam_internal(_map, [], set), do: set

  def trace_beam_internal(map, [{row, col, direction} | rest], set) do
    cond do
      {row, col, direction} in set ->
        trace_beam_internal(map, rest, set)

      !Map.has_key?(map, {row, col}) ->
        trace_beam_internal(map, rest, set)

      true ->
        sym = Map.get(map, {row, col})

        next = get_next(sym, {row, col, direction})

        trace_beam_internal(map, next ++ rest, MapSet.put(set, {row, col, direction}))
    end
  end

  def get_next(sym, {row, col, :right}) when sym == "." when sym == "-",
    do: [{row, col + 1, :right}]

  def get_next(sym, {row, col, :left}) when sym == "." when sym == "-",
    do: [{row, col - 1, :left}]

  def get_next(sym, {row, col, :up}) when sym == "." when sym == "|",
    do: [{row - 1, col, :up}]

  def get_next(sym, {row, col, :down}) when sym == "." when sym == "|",
    do: [{row + 1, col, :down}]

  def get_next("|", {row, col, dir}) when dir == :right when dir == :left,
    do: [{row - 1, col, :up}, {row + 1, col, :down}]

  def get_next("-", {row, col, dir}) when dir == :up when dir == :down,
    do: [{row, col - 1, :left}, {row, col + 1, :right}]

  def get_next("/", {row, col, :left}),
    do: [{row + 1, col, :down}]

  def get_next("/", {row, col, :right}),
    do: [{row - 1, col, :up}]

  def get_next("/", {row, col, :up}),
    do: [{row, col + 1, :right}]

  def get_next("/", {row, col, :down}),
    do: [{row, col - 1, :left}]

  def get_next("\\", {row, col, :left}),
    do: [{row - 1, col, :up}]

  def get_next("\\", {row, col, :right}),
    do: [{row + 1, col, :down}]

  def get_next("\\", {row, col, :up}),
    do: [{row, col - 1, :left}]

  def get_next("\\", {row, col, :down}),
    do: [{row, col + 1, :right}]

  def count_energized(energized_set) do
    energized_set
    |> Enum.map(fn {row, col, _} -> {row, col} end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def construct_starts(rows, _cols) do
    for var <- 0..rows do
      [
        {0, var, :down},
        {var, 0, :right},
        {rows, var, :up},
        {var, rows, :left}
      ]
    end
    |> List.flatten()
  end

  def run_all(starts, map) do
    Enum.map(starts, fn start -> Task.async(fn -> trace_beam_and_count(map, start) end) end)
    |> Task.await_many(:infinity)
    |> Enum.max()
  end
end
