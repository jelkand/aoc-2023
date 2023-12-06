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
    |> Enum.map(fn [destination_start, source_start, range_size] ->
      {
        source_start..(source_start + range_size - 1),
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
    seeds
    |> Enum.map(&process_seed(&1, maps))
    |> Enum.map(&Integer.to_string/1)
    |> IO.inspect(label: "right")

    all_maps = combine_all_maps(maps)
    # c|> IO.inspect(label: "map")

    seeds
    |> Enum.map(fn seed -> process_map(seed, all_maps) end)
    |> Enum.map(&Integer.to_string/1)
    |> IO.inspect(label: "wrong")

    # |> Enum.min()
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
    # IO.inspect(fertilizer_water, label: "fertilizer_water")

    seed_soil
    # |> IO.inspect(label: "seed soil")
    |> combine_maps(soil_fertilizer)

    # |> IO.inspect(label: "soil fertilizer")
    |> combine_maps(fertilizer_water)
    |> combine_maps(water_light)
    |> combine_maps(light_temp)
    |> combine_maps(temp_humid)
    |> combine_maps(humid_loc)
  end

  def combine_maps(first, second) do
    combine(first, second, [])
  end

  def combine([], [], acc), do: acc
  def combine([], to_merge, acc), do: to_merge ++ acc

  def combine([first | tail], to_merge, acc) do
    {original_range, offset} = first

    # need to match on the output of the first map
    {match, updated_to_merge} =
      get_range_and_update_map(Range.shift(original_range, offset), to_merge)

    {calculated, leftover_to_match, leftover_ranges} =
      handle_match(first, match)

    # |> IO.inspect(label: "calculated, leftover to match, leftover ranges")

    combine(leftover_to_match ++ tail, leftover_ranges ++ updated_to_merge, calculated ++ acc)
  end

  def get_range_and_update_map(find_range, map) do
    match =
      Enum.find(map, fn {range, _} -> !Range.disjoint?(find_range, range) end)

    {match, map -- [match]}
  end

  def handle_match(first, nil), do: {[first], [], []}

  def handle_match({original_range, offset}, {m1..m2 = match_range, match_offset}) do
    # IO.inspect({Range.shift(original_range, offset), offset, match_range, match_offset},
    #   label: "handling"
    # )

    r1..r2 = Range.shift(original_range, offset)
    # shift the intersection up
    intersection = max(r1, m1)..min(r2, m2)
    # IO.inspect(intersection, label: "intersection")

    non_intersecting =
      handle_intersection(Range.shift(original_range, offset), intersection)

    # |> IO.inspect(label: "range non intersecting")

    # don't shift the match ranges
    match_non_intersecting =
      handle_intersection(match_range, intersection)

    # |> IO.inspect(label: "match non intersecting")

    # unshift the range to return it 
    calculated = [{Range.shift(intersection, -offset), offset + match_offset}]
    # unshift this as we'll shift it again in the next match
    leftover_to_match = Enum.map(non_intersecting, &{Range.shift(&1, -offset), offset})
    # these are left as they are because they are already "outputs"
    leftovers = Enum.map(match_non_intersecting, &{&1, match_offset})

    {
      calculated,
      leftover_to_match,
      leftovers
    }
  end

  def handle_intersection(r1..r2 = _range, i1..i2 = intersection) do
    [r1..(i1 - 1), (i2 + 1)..r2] |> Enum.filter(&Range.disjoint?(&1, intersection))
  end

  def concatenate_lists(first, second) do
    first ++ second
  end

  # def sort_ranges(list),
  #   do:
  #     Enum.sort(list, fn {a1..b1, _}, {a2..b2, _} ->
  #       cond do
  #         a1 == a2 -> b1 < b2
  #         true -> a1 < a2
  #       end
  #     end)

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
