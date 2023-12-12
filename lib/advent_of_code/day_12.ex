defmodule AdventOfCode.Day12 do
  # 8832 too high
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
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(&parse_line/1)
  end

  def parse_line([spring_list, broken_lengths]) do
    {
      String.split(spring_list, "", trim: true),
      String.split(broken_lengths, ",", trim: true) |> Enum.map(&String.to_integer/1)
    }
  end

  def solve_1(springs) do
    springs
    |> Enum.map(&solve_line/1)
    |> List.flatten()
    |> length()
  end

  def solve_line({springs, broken_sections}) do
    solve_line_internal({springs, broken_sections})
  end

  def solve_line_internal({springs, []}),
    do:
      springs
      |> Enum.join("")
      |> String.replace("S", ".")
      |> String.replace("P", "#")

  def solve_line_internal({springs, [first_section_size | rest]}) do
    potential_placements =
      springs
      |> Enum.with_index()
      |> Enum.chunk_every(first_section_size, 1)
      |> Enum.filter(fn chunk ->
        {{_, min_idx}, {_, max_idx}} = Enum.min_max_by(chunk, &elem(&1, 1))
        first_spring = Enum.find_index(springs, fn sym -> sym == "#" end)

        Enum.all?(chunk, fn {sym, _} -> sym in ["?", "#"] end) and
          (min_idx == 0 or Enum.at(springs, min_idx - 1, ".") not in ["#", "P"]) and
          Enum.at(springs, max_idx + 1, ".") not in ["#", "P"] and
          min_idx <= first_spring
      end)
      |> Enum.map(fn chunk -> Enum.map(chunk, &elem(&1, 1)) end)

    recursion_args =
      Enum.map(potential_placements, fn chunk ->
        springs
        |> Enum.with_index()
        |> Enum.map(fn {sym, idx} ->
          {min_idx, _max_idx} = Enum.min_max(chunk)

          cond do
            sym in ["?", "#"] and idx in chunk -> "P"
            sym == "?" and idx < min_idx -> "S"
            true -> sym
          end
        end)
      end)

    Enum.reduce(recursion_args, [], fn next_springs, inner_acc ->
      this_child = solve_line_internal({next_springs, rest})

      if this_child, do: [this_child | inner_acc], else: inner_acc
    end)
    |> List.flatten()
    |> Enum.uniq()
  end
end
