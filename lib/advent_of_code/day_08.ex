defmodule AdventOfCode.Day08 do
  def part1(args) do
    parse_input(args)
    |> solve_1("A", "Z")
    |> elem(1)
  end

  def part2(args) do
    parse_input(args) |> solve_2("A", "Z")
  end

  def parse_input(input) do
    [raw_instructions, raw_map] = String.split(input, "\n\n", trim: true)

    instructions =
      String.split(raw_instructions, "", trim: true)
      |> Enum.map(&direction_to_index/1)
      |> List.to_tuple()

    map =
      raw_map |> String.split("\n", trim: true) |> Enum.map(&parse_map_line/1) |> Enum.into(%{})

    {instructions, map}
  end

  def direction_to_index("R"), do: 1
  def direction_to_index("L"), do: 0

  def parse_map_line(line) do
    [key, raw_value] = String.split(line, " = ", trim: true)

    [left, right] = raw_value |> String.replace(~r/\(|\)/, "") |> String.split(", ", trim: true)
    {string_to_tuple(key), {string_to_tuple(left), string_to_tuple(right)}}
  end

  def string_to_tuple(string), do: string |> String.split("", trim: true) |> List.to_tuple()

  def solve_1({instructions, map}, start, target) do
    first =
      Map.keys(map)
      |> Enum.find(fn key -> Enum.all?(key |> Tuple.to_list(), fn char -> char == start end) end)

    iterate_map(first, target, {instructions, map}, 0)
  end

  def iterate_map(position, target, {instructions, map} = inputs, steps, :continue) do
    direction = get_direction(instructions, steps)
    next = Map.get(map, position) |> elem(direction)

    iterate_map(next, target, inputs, steps + 1)
  end

  def iterate_map(position, target, _inputs, steps)
      when elem(position, tuple_size(position) - 1) == target,
      do: {position, steps}

  def iterate_map(position, target, {instructions, map} = inputs, steps) do
    direction = get_direction(instructions, steps)
    next = Map.get(map, position) |> elem(direction)

    iterate_map(next, target, inputs, steps + 1)
  end

  def get_direction(instructions, steps) do
    index = rem(steps, tuple_size(instructions))
    elem(instructions, index)
  end

  def solve_2({_instructions, map} = inputs, start, target) do
    all_starts = Map.keys(map) |> Enum.filter(fn {_, _, c} -> c == start end)

    first_cycle_sizes =
      Enum.map(all_starts, &iterate_map(&1, target, inputs, 0))
      |> Enum.map(&elem(&1, 1))

    reduce_lcms(first_cycle_sizes)
  end

  def reduce_lcms([only]), do: only

  def reduce_lcms([first, second | rest]) do
    reduce_lcms([Math.lcm(first, second) | rest])
  end
end
