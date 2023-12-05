defmodule AdventOfCode.Day05 do
  def part1(args) do
    args
    |> parse_input()
    |> solve_1()
  end

  def part2(args) do
  end

  def parse_input(input, flag) do
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
  end

  def maybe_chunk_and_range(list, _), do: list

  def parse_map(map_str) do
    map_str
    |> String.split("\n", trim: true)
    |> tl()
    |> Enum.map(&list_to_ints/1)
    |> Enum.map(fn [destination_start, source_start, offset] ->
      {source_start..(source_start + offset - 1), destination_start,
       destination_start - source_start}
    end)
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
    {_, _, offset} =
      Enum.find(map, {number, number, 0}, fn {source_rng, _dest_start, _offset} ->
        number in source_rng
      end)

    number + offset
  end
end
