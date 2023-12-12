defmodule AdventOfCode.Day12 do
  use Memoize

  def part1(args) do
    {:ok, _} = Application.ensure_all_started(:memoize)

    parse_input(args)
    |> solve()
  end

  def part2(args) do
    {:ok, _} = Application.ensure_all_started(:memoize)
    parse_input(args) |> expand_input() |> solve()
  end

  def solve(input) do
    input
    |> Enum.map(&solve_line/1)
    |> Enum.map(fn springs -> Enum.map(springs, &String.replace(&1, "?", ".")) end)
    |> Enum.map(&Enum.uniq/1)
    |> Enum.map(&length/1)
    |> Enum.sum()
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

  def solve_line({springs, broken_sections}) do
    solve_line_internal({springs, broken_sections})
  end

  defmemo(solve_line_internal({[], sections}) when sections != [],
    do: [nil]
  )

  defmemo solve_line_internal({unassigned_springs, []}) do
    cond do
      Enum.any?(unassigned_springs, &(&1 == "#")) -> [nil]
      true -> unassigned_springs |> Enum.join("") |> List.wrap()
    end
  end

  defmemo solve_line_internal({springs_to_assign, [first_section_size | rest]}) do
    potential_placements =
      springs_to_assign
      |> Enum.with_index()
      |> Enum.chunk_every(first_section_size, 1, :discard)
      |> Enum.filter(fn chunk ->
        {{_, min_idx}, {_, max_idx}} = Enum.min_max_by(chunk, &elem(&1, 1))
        first_spring = Enum.find_index(springs_to_assign, fn sym -> sym == "#" end)

        Enum.all?(chunk, fn {sym, _} -> sym in ["#", "?"] end) and
          Enum.at(springs_to_assign, max_idx + 1, ".") != "#" and
          min_idx <= first_spring
      end)
      |> Enum.map(fn chunk -> Enum.map(chunk, &elem(&1, 1)) end)

    recursion_args =
      Enum.map(potential_placements, fn chunk ->
        {_min_idx, max_idx} = Enum.min_max(chunk)

        {assigned, remaining} =
          springs_to_assign
          |> Enum.with_index()
          |> Enum.map(fn {sym, idx} ->
            cond do
              sym in ["?", "#"] and idx in chunk -> "#"
              sym == "?" and idx <= max_idx + 1 -> "."
              true -> sym
            end
          end)
          |> Enum.split(max_idx + 2)

        {assigned, remaining}
      end)

    Enum.map(recursion_args, fn {assigned, remaining} ->
      assigned_str = Enum.join(assigned, "")
      args = {remaining, rest}

      solve_line_internal(args)
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(&(assigned_str <> &1))
    end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def validate_output(output, input) do
    chunks = input |> Enum.map(&elem(&1, 1))

    Enum.zip(chunks, output)
    |> Enum.map(fn {chunked, outputs} ->
      Enum.map(outputs, fn str ->
        String.split(str, ".", trim: true) |> Enum.map(&String.length/1)
      end)
      |> Enum.filter(fn translated -> translated == chunked end)
    end)
  end

  def expand_input(input) do
    Enum.map(input, fn {springs, chunks} ->
      # this is horrible lol
      {springs ++ ["?"] ++ springs ++ ["?"] ++ springs ++ ["?"] ++ springs ++ ["?"] ++ springs,
       chunks ++ chunks ++ chunks ++ chunks ++ chunks}
    end)
  end
end
