defmodule AdventOfCode.Day15 do
  def part1(args) do
    args
    |> parse_input()
    |> hash_all()
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> process_lenses()
    |> score()
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def hash_all(charlists) do
    Enum.map(charlists, &hash_charlist/1)
  end

  def hash_charlist(charlist) do
    hash_charlist_internal(charlist, 0)
  end

  def hash_charlist_internal([], value), do: value

  def hash_charlist_internal([first | rest], value) do
    next_value =
      ((value + first) * 17)
      |> rem(256)

    hash_charlist_internal(rest, next_value)
  end

  def process_lenses(lens_box_map) do
    Enum.reduce(lens_box_map, %{}, &process_lens/2)
  end

  def process_lens(lens, acc) do
    cond do
      ?= in lens -> put_lens(lens, acc)
      ?- in lens -> remove_lens(lens, acc)
      true -> acc
    end
  end

  def put_lens(lens, acc) do
    {label, focal_length} = Enum.split_while(lens, &(&1 != ?=))

    box = hash_charlist(label)
    string_label = List.to_string(label)
    num_focal_length = focal_length |> tl() |> List.to_string() |> String.to_integer()

    to_insert = {string_label, num_focal_length}

    Map.update(acc, box, [to_insert], fn box_contents ->
      case Enum.find_index(box_contents, fn {inner_label, _} -> inner_label == string_label end) do
        nil -> [to_insert | box_contents]
        idx -> List.replace_at(box_contents, idx, to_insert)
      end
    end)
  end

  def remove_lens(lens, acc) do
    label = Enum.take_while(lens, &(&1 != ?-))

    box = hash_charlist(label)

    string_label = List.to_string(label)

    Map.update(acc, box, [], fn box_contents ->
      Enum.filter(box_contents, fn {inner_label, _focal_length} ->
        string_label !== inner_label
      end)
    end)
  end

  def score(map) do
    Enum.reduce(map, 0, fn {box_number, box_contents}, acc ->
      box_contents
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.reduce(acc, fn {{_label, focal_length}, idx}, acc ->
        (box_number + 1) * idx * focal_length + acc
      end)
    end)
  end
end
