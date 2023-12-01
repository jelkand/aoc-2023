defmodule AdventOfCode.Day01 do
  def parse("", nums, _), do: Enum.reverse(nums)
  def parse("1" <> rest, nums, part), do: parse(rest, [1 | nums], part)
  def parse("2" <> rest, nums, part), do: parse(rest, [2 | nums], part)
  def parse("3" <> rest, nums, part), do: parse(rest, [3 | nums], part)
  def parse("4" <> rest, nums, part), do: parse(rest, [4 | nums], part)
  def parse("5" <> rest, nums, part), do: parse(rest, [5 | nums], part)
  def parse("6" <> rest, nums, part), do: parse(rest, [6 | nums], part)
  def parse("7" <> rest, nums, part), do: parse(rest, [7 | nums], part)
  def parse("8" <> rest, nums, part), do: parse(rest, [8 | nums], part)
  def parse("9" <> rest, nums, part), do: parse(rest, [9 | nums], part)

  def parse("one" <> rest, nums, :part_2), do: parse("e" <> rest, [1 | nums], :part_2)
  def parse("two" <> rest, nums, :part_2), do: parse("o" <> rest, [2 | nums], :part_2)
  def parse("three" <> rest, nums, :part_2), do: parse("e" <> rest, [3 | nums], :part_2)
  def parse("four" <> rest, nums, :part_2), do: parse("r" <> rest, [4 | nums], :part_2)
  def parse("five" <> rest, nums, :part_2), do: parse("e" <> rest, [5 | nums], :part_2)
  def parse("six" <> rest, nums, :part_2), do: parse("x" <> rest, [6 | nums], :part_2)
  def parse("seven" <> rest, nums, :part_2), do: parse("n" <> rest, [7 | nums], :part_2)
  def parse("eight" <> rest, nums, :part_2), do: parse("t" <> rest, [8 | nums], :part_2)
  def parse("nine" <> rest, nums, :part_2), do: parse("e" <> rest, [9 | nums], :part_2)
  def parse(<<_head::size(8), rest::binary>>, nums, part), do: parse(rest, nums, part)

  def get_calibration(num_list), do: List.first(num_list) * 10 + List.last(num_list)

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end

  def part1(args) do
    args
    |> parse_input()
    |> Enum.map(&parse(&1, [], :part_1))
    |> Enum.map(&get_calibration/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.map(&parse(&1, [], :part_2))
    |> Enum.map(&get_calibration/1)
    |> Enum.sum()
  end

  @number_representations %{
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9,
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9
  }

  def solve_1(parsed_input) do
    parsed_input
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&get_first_and_last_digits/1)
    |> Enum.sum()
  end

  def solve_2(parsed_input) do
    parsed_input
    |> Enum.map(&get_first_and_last_digits_2/1)
    |> Enum.sum()
  end

  def get_first_and_last_digits(line) do
    first =
      get_first_digit_in_line(line)

    last = line |> Enum.reverse() |> get_first_digit_in_line()

    first * 10 + last
  end

  def get_first_and_last_digits_2(line) do
    splits =
      Enum.map(Map.keys(@number_representations), fn number ->
        {number, String.split(line, number)}
      end)

    first =
      Enum.min_by(splits, fn {_number, [split_head | _]} ->
        String.length(split_head)
      end)
      |> elem(0)
      |> string_to_integer()

    last =
      Enum.min_by(splits, fn {_number, split_line} ->
        Enum.reverse(split_line)
        |> hd()
        |> String.length()
      end)
      |> elem(0)
      |> string_to_integer()

    first * 10 + last
  end

  def string_to_integer(string) do
    Map.get(@number_representations, string)
  end

  def get_first_digit_in_line(line) do
    Enum.find_value(line, fn char ->
      case Integer.parse(char) do
        {int, ""} -> int
        _ -> false
      end
    end)
  end

  # def part1(args) do
  #   args
  #   |> parse_input()
  #   |> solve_1()
  # end

  # def part2(args) do
  #   args
  #   |> parse_input()
  #   |> solve_2()
  # end
end
