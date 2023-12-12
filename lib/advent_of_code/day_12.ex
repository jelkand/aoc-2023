defmodule AdventOfCode.Day12 do
  def part1(args) do
    parse_input(args)
    |> solve()
  end

  def part2(args) do
    parse_input(args) |> expand_input() |> solve()
  end

  def solve(input) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)

    # filter out all of the ones that had trailing #'s
    input
    # |> Enum.at(3)
    # |> List.wrap()
    |> Enum.map(&solve_line/1)
    # |> validate_output(input)
    |> Enum.map(&length/1)
    |> dbg
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
    solve_line_internal({springs, broken_sections}, [])
  end

  def solve_line_internal({[], []}, string_so_far),
    do:
      string_so_far
      |> dbg()
      |> Enum.reverse()
      |> Enum.join("")
      |> String.replace("S", ".")
      |> String.replace("P", "#")
      |> String.replace("?", ".")

  def solve_line_internal({springs, []}, string_so_far) do
    cond do
      Enum.any?(springs, &(&1 == "#")) -> nil
      true -> solve_line_internal({[], []}, [springs | string_so_far])
    end
  end

  def solve_line_internal({springs, [first_section_size | rest]}, string_so_far) do
    # dbg()

    potential_placements =
      springs
      |> Enum.with_index()
      |> Enum.chunk_every(first_section_size, 1)
      |> Enum.filter(fn chunk ->
        {{_, min_idx}, {_, max_idx}} = Enum.min_max_by(chunk, &elem(&1, 1))
        first_spring = Enum.find_index(springs, fn sym -> sym == "#" end)

        (min_idx == 0 or Enum.at(springs, min_idx - 1, ".") not in ["#", "P"]) and
          Enum.all?(chunk, fn {sym, _} -> sym in ["?", "#"] end) and
          Enum.at(springs, max_idx + 1, ".") not in ["#", "P"] and
          min_idx <= first_spring
      end)
      |> Enum.map(fn chunk -> Enum.map(chunk, &elem(&1, 1)) end)

    recursion_args =
      Enum.map(potential_placements, fn chunk ->
        {min_idx, max_idx} = Enum.min_max(chunk)

        {assigned, remaining} =
          springs
          |> Enum.with_index()
          |> Enum.map(fn {sym, idx} ->
            cond do
              sym in ["?", "#"] and idx in chunk -> "#"
              sym == "?" and idx < min_idx -> "."
              true -> sym
            end
          end)
          |> Enum.split(max_idx + 2)

        {assigned, remaining}
      end)

    Enum.reduce(recursion_args, [], fn {assigned, remaining}, inner_acc ->
      dbg()
      # cached = Agent.get(__MODULE__, &Map.get(&1, {next_springs, rest}))

      # this_child =
      #   if cached do
      #     cached
      #   else
      #     new = solve_line_internal({next_springs, rest})
      #     Agent.update(__MODULE__, &Map.put(&1, {next_springs, rest}, new))
      #   end

      this_child = solve_line_internal({remaining, rest}, [assigned | string_so_far])

      if this_child, do: [this_child | inner_acc], else: inner_acc
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
