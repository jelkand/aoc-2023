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
    # seeds
    # |> Enum.map(&process_seed(&1, maps))

    all_maps = combine_all_maps(maps)

    seeds
    |> Enum.map(fn seed -> Map.get(all_maps, seed) end)
    |> IO.inspect()
    |> Enum.min()
  end

  def solve_2(
        %{
          seeds: seeds
        } = maps
      ) do
    # combined_maps = combine_all_maps(maps)
    # |> IO.inspect(limit: :infinity)
  end

  def combine_all_maps(%{
        seed_soil: seed_soil,
        soil_fertilizer: soil_fertilizer,
        fertilizer_water: fertilizer_water,
        water_light: water_light,
        light_temp: light_temp,
        temp_humid: temp_humid,
        humid_loc: humid_loc
      }) do
    # IO.inspect(soil_fertilizer, label: "soil_fertilizer")

    seed_soil
    |> expand_map()
    |> combine_maps(soil_fertilizer)
    |> combine_maps(fertilizer_water)
    |> combine_maps(water_light)
    |> combine_maps(light_temp)
    |> combine_maps(temp_humid)
    |> combine_maps(humid_loc)
  end

  def expand_map(list) do
    list
    # |> IO.inspect(label: "list to expand")
    |> Enum.flat_map(fn {rng, offset} ->
      IO.inspect({rng, offset})

      Enum.map(rng, fn val ->
        # if val == 53, do: IO.inspect({val, offset, val + offset})

        {val, val + offset}
      end)
    end)
    |> Enum.into(%{})

    # |> IO.inspect(label: "expanded")
  end

  def combine_maps(first, second) do
    expanded = expand_map(second)

    second_not_in_first =
      Enum.filter(expanded, fn {k, _v} ->
        k not in Map.values(first) and not Map.has_key?(first, k)
      end)

    # |> IO.inspect(label: "not in first")

    IO.inspect(Map.get(expanded, 53), label: "53")

    first
    |> Enum.reduce([], fn {k, v}, acc ->
      [{k, Map.get(expanded, v, v)} | acc]
    end)
    |> concatenate_lists(second_not_in_first)
    |> Enum.into(%{})
  end

  def concatenate_lists(first, second) do
    first ++ second
  end

  def get_left_disjoint(a1.._b1, a2.._b2) when a1 == a2, do: nil
  # def get_left_disjoint(a1..b1, a2.._b2), do: a1..min(a2, b1)
  def get_left_disjoint(a1..b1, a2.._b2), do: a1..(a2 - 1)

  def get_overlap(_a1..b1, a2.._b2) when a2 > b1, do: nil
  def get_overlap(_a1..b1, a2.._b2), do: a2..b1

  def get_right_disjoint(_a1..b1, _a2..b2) when b1 == b2, do: nil
  def get_right_disjoint(a1..b1, a2..b2) when a1 < a2 and b1 < b2, do: (b1 + 1)..b2
  def get_right_disjoint(a1..b1, a2..b2) when a1 < a2 and b1 > b2, do: (b2 + 1)..b1
  def get_right_disjoint(_a1..b1, a2..b2), do: (max(a2, b1) + 1)..max(b2, a2)
  # def get_right_disjoint(a1..b1, a2..b2), do: (b1 + 1)..max(b2, a1)

  def filter_nils(list), do: Enum.filter(list, fn {rng, _} -> rng != nil end)

  def sort_ranges(list),
    do:
      Enum.sort(list, fn {a1..b1, _}, {a2..b2, _} ->
        cond do
          a1 == a2 -> b1 < b2
          true -> a1 < a2
        end
      end)

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
