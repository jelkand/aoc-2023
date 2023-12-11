defmodule AdventOfCode.Day10 do
  def part1(args) do
    args
    |> parse_input()
    |> solve_1()
  end

  def part2(args) do
    map = parse_input(args)

    {rows, cols} = get_input_size(args)

    start_position = Enum.find(map, fn {_pos, {symbol, _}} -> symbol == "S" end) |> elem(0)

    neighbors_set =
      Enum.filter(map, fn {_, {_, neighbors}} -> start_position in neighbors end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    s_symbol = classify_s(start_position, neighbors_set)

    pipe_coordinates = build_pipe(map) |> to_coord_set()

    map_with_corrected_s = Map.put(map, start_position, {s_symbol, []})

    ray_trace_pipe(rows, cols, pipe_coordinates, map_with_corrected_s) |> elem(0)
  end

  def get_input_size(args) do
    split = String.split(args, "\n", trim: true)

    {length(split), split |> hd() |> String.length()}
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

  def get_neighbors(_, _), do: []

  def solve_1(map) do
    {start_position, _} = Enum.find(map, fn {_pos, {symbol, _}} -> symbol == "S" end)

    [left, right] =
      Enum.filter(map, fn {_, {_, neighbors}} -> start_position in neighbors end)

    next_pair({left, start_position}, {right, start_position}, map, 1)
  end

  def next_pair({{lpos, _}, _}, {{rpos, _}, _}, _, count)
      when lpos == rpos,
      do: count

  def next_pair(left, right, map, count) do
    next_pair(get_next(left, map), get_next(right, map), map, count + 1)
  end

  def get_next({{pos, {_, neighbors}}, came_from}, map) do
    next_pos = List.delete(neighbors, came_from) |> hd()
    next = Map.get(map, next_pos)
    {{next_pos, next}, pos}
  end

  def build_pipe(map) do
    {start_position, _} = start = Enum.find(map, fn {_pos, {symbol, _}} -> symbol == "S" end)

    next =
      Enum.filter(map, fn {_, {_, neighbors}} -> start_position in neighbors end) |> hd()

    next_position({next, start_position}, map, [start])
  end

  def next_position({{_pos, {sym, _neighbors}}, _}, _map, acc) when sym == "S",
    do: Enum.reverse(acc)

  def next_position({current_pos, _came_from} = current, map, acc) do
    next = get_next(current, map)
    next_position(next, map, [current_pos | acc])
  end

  def to_coord_set(list) do
    list |> Enum.map(&elem(&1, 0)) |> MapSet.new()
  end

  def ray_trace_pipe(rows, cols, pipe_coordinates, map) do
    Enum.reduce(0..(rows - 1), {0, 0}, fn row, {inside, outside} ->
      {i, o, _} =
        Enum.reduce(0..(cols - 1), {inside, outside, 0}, fn col,
                                                            {this_row_inside, this_row_outside,
                                                             pipe_count} ->
          cond do
            {row, col} in pipe_coordinates ->
              {this_row_inside, this_row_outside,
               maybe_increment_pipe_count(pipe_count, {row, col}, map)}

            true ->
              if rem(pipe_count, 2) == 1 do
                {this_row_inside + 1, this_row_outside, pipe_count}
              else
                {this_row_inside, this_row_outside + 1, pipe_count}
              end
          end
        end)

      {i, o}
    end)
  end

  def maybe_increment_pipe_count(pipe_count, pos, map) do
    {symbol, _} = Map.get(map, pos)

    case symbol in ["J", "L", "|"] do
      true -> pipe_count + 1
      false -> pipe_count
    end
  end

  def classify_s(position, neighbors_set) do
    cond do
      neighbors_set == get_neighbors("|", position) |> MapSet.new() -> "|"
      neighbors_set == get_neighbors("-", position) |> MapSet.new() -> "-"
      neighbors_set == get_neighbors("L", position) |> MapSet.new() -> "L"
      neighbors_set == get_neighbors("J", position) |> MapSet.new() -> "J"
      neighbors_set == get_neighbors("7", position) |> MapSet.new() -> "7"
      neighbors_set == get_neighbors("F", position) |> MapSet.new() -> "F"
    end
  end
end
