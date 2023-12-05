defmodule AdventOfCode.Day05 do
  def part1(args) do
    args
    |> parse_input()
    |> solve_1()
  end

  def part2(args) do
    args
    |> parse_input(:part_2)
    |> solve_2()
  end

  def parse_input(input, flag \\ nil) do
    [
      seeds_str,
      seed_soil_str,
      soil_fertilizer_str,
      fertilizer_water_str,
      water_light_str,
      light_temp_str,
      temp_humid_str,
      humid_loc_str
    ] = String.split(input, "\n\n", trim: true)

    with seeds <- parse_seeds(seeds_str, flag),
         seed_soil_map <- parse_map(seed_soil_str),
         soil_fertilizer_map <- parse_map(soil_fertilizer_str),
         fertilizer_water_map <- parse_map(fertilizer_water_str),
         water_light_map <- parse_map(water_light_str),
         light_temp_map <- parse_map(light_temp_str),
         temp_humid_map <- parse_map(temp_humid_str),
         humid_loc_map <- parse_map(humid_loc_str) do
      %{
        seeds: seeds,
        seed_soil: seed_soil_map,
        soil_fertilizer: soil_fertilizer_map,
        fertilizer_water: fertilizer_water_map,
        water_light: water_light_map,
        light_temp: light_temp_map,
        temp_humid: temp_humid_map,
        humid_loc: humid_loc_map
      }
    end
  end

  def parse_seeds(seeds_str, flag) do
    seeds_str
    |> String.split(": ", trim: true)
    |> List.last()
    |> list_to_ints()
    |> maybe_chunk_and_range(flag)
  end

  def maybe_chunk_and_range(list, :part_2) do
    list
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> a..(a + b - 1) end)
  end

  def maybe_chunk_and_range(list, _), do: list

  def parse_map(map_str) do
    map_str
    |> String.split("\n", trim: true)
    |> tl()
    |> Enum.map(&list_to_ints/1)
    |> Enum.map(fn [destination_start, source_start, offset] ->
      {
        source_start..(source_start + offset - 1),
        destination_start - source_start
      }
    end)
    |> Enum.sort_by(fn {a.._, _} -> a end)
  end

  def list_to_ints(str_list) do
    str_list
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve_1(
        %{
          seeds: seeds
        } = maps
      ) do
    seeds |> Enum.map(&process_seed(&1, maps)) |> Enum.min()
  end

  def solve_2(
        %{
          seeds: seeds,
          seed_soil: seed_soil,
          soil_fertilizer: soil_fertilizer,
          fertilizer_water: fertilizer_water,
          water_light: water_light,
          light_temp: light_temp,
          temp_humid: temp_humid,
          humid_loc: humid_loc
        } = maps
      ) do
    IO.puts("\n")

    seed_soil
    |> combine_maps(soil_fertilizer)
    |> IO.inspect(label: "seed fertilizer")

    # |> combine_maps(fertilizer_water)
    # |> IO.inspect(label: "seed water")

    # |> combine_maps(water_light)
    # |> combine_maps(light_temp)
    # |> combine_maps(temp_humid)
    # |> combine_maps(humid_loc)

    # |> IO.inspect()
  end

  def combine_maps(first, second) do
    combine(first, second, [])
  end

  def combine([], [], acc), do: Enum.reverse(acc)
  def combine([], second, acc), do: (Enum.reverse(second) ++ acc) |> Enum.reverse()
  def combine(first, [], acc), do: (Enum.reverse(first) ++ acc) |> Enum.reverse()

  def combine(
        [{a.._, _} = first_head | first_tail],
        [{b.._, _} = second_head | second_tail],
        acc
      ) do
    IO.inspect({[first_head | first_tail], [second_head | second_tail]}, label: "inputs")

    [{first_rng, first_offset}, {second_rng, second_offset}] =
      [first_head, second_head] |> sort_ranges

    IO.inspect([{first_rng, first_offset}, {second_rng, second_offset}], label: "combining")

    # left = {get_left_disjoint(first_rng, second_rng), first_offset}
    # overlap = {get_overlap(first_rng, second_rng), first_offset + second_offset}
    # right = {get_right_disjoint(first_rng, second_rng), second_offset}
    left = get_left_disjoint(first_rng, second_rng)
    overlap = get_overlap(first_rng, second_rng)
    right = get_right_disjoint(first_rng, second_rng)

    IO.inspect({left, overlap, right}, label: "left, overlap, right")

    IO.puts("\n")

    # {next_first, next_second} =
    cond do
      overlap == nil ->
        combine(
          first_tail,
          filter_nils([right | second_tail]) |> sort_ranges(),
          ([{left, first_offset}] |> filter_nils()) ++ acc
        )

      a > b ->
        combine(
          [right | first_tail] |> filter_nils() |> sort_ranges(),
          second_tail,
          ([{overlap, second_offset + first_offset}, {left, first_offset}]
           |> filter_nils()) ++ acc
        )

      true ->
        combine(
          first_tail,
          filter_nils([right | second_tail]) |> sort_ranges(),
          filter_nils([{overlap, second_offset + first_offset}, {left, first_offset}]) ++ acc
        )

        # {first_tail, filter_nils([right | second_tail]) |> sort_ranges()}
    end

    # combine(next_first, next_second, filter_nils([overlap, left]) ++ acc)
  end

  def get_left_disjoint(a1.._b1, a2.._b2) when a1 == a2, do: nil
  def get_left_disjoint(a1..b1, a2.._b2), do: a1..min(a2, b1)

  def get_overlap(_a1..b1, a2.._b2) when a2 > b1, do: nil
  def get_overlap(_a1..b1, a2.._b2), do: a2..b1

  def get_right_disjoint(_a1..b1, _a2..b2) when b1 == b2, do: nil
  def get_right_disjoint(_a1..b1, a2..b2), do: max(a2, b1 + 1)..b2

  def filter_nils(list), do: Enum.filter(list, fn {rng, _} -> rng != nil end)
  def sort_ranges(list), do: Enum.sort_by(list, fn {a.._, _} -> a end)

  def process_seed(seed, %{
        seed_soil: seed_soil,
        soil_fertilizer: soil_fertilizer,
        fertilizer_water: fertilizer_water,
        water_light: water_light,
        light_temp: light_temp,
        temp_humid: temp_humid,
        humid_loc: humid_loc
      }) do
    seed
    |> process_map(seed_soil)
    |> process_map(soil_fertilizer)
    |> process_map(fertilizer_water)
    |> process_map(water_light)
    |> process_map(light_temp)
    |> process_map(temp_humid)
    |> process_map(humid_loc)
  end

  def process_map(number, map) do
    {_, offset} =
      Enum.find(map, {number, 0}, fn {src_rng, _offset} ->
        number in src_rng
      end)

    number + offset
  end
end
