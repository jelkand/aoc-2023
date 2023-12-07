defmodule AdventOfCode.Day07 do
  # 246811230 too low
  def part1(args) do
    args
    |> parse_input()
    |> classify_hands()
    |> sort_hands()
    |> score_hands()
    |> Enum.sum()
  end

  def part2(_args) do
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [hand, bid] ->
      {String.split(hand, "", trim: true)
       |> replace_face_cards()
       |> Enum.map(&String.to_integer/1), String.to_integer(bid)}
    end)
  end

  def replace_face_cards(hand) do
    Enum.map(hand, &maybe_replace_card/1)
  end

  def maybe_replace_card("K"), do: "13"
  def maybe_replace_card("Q"), do: "12"
  def maybe_replace_card("J"), do: "11"
  def maybe_replace_card("T"), do: "10"
  def maybe_replace_card("A"), do: "14"
  def maybe_replace_card(card), do: card

  def classify_hands(hands) do
    hands
    |> Enum.map(&preprocess_hand/1)
  end

  def preprocess_hand({hand, bid}) do
    type =
      hand
      |> Enum.group_by(fn card -> card end)
      |> Map.values()
      |> Enum.map(fn group -> length(group) end)
      |> Enum.sort(:desc)
      |> classify_hand()

    {[type | hand], bid}
  end

  # :five_of_a_kind
  def classify_hand([5 | _]), do: 7
  # :four_of_a_kind
  def classify_hand([4 | _]), do: 6
  # :full_house
  def classify_hand([3, 2 | _]), do: 5
  # :three_of_a_kind
  def classify_hand([3 | _]), do: 4
  # :two_pair
  def classify_hand([2, 2 | _]), do: 3
  # :one_pair
  def classify_hand([2 | _]), do: 2
  # :high_card
  def classify_hand([1 | _]), do: 1

  def sort_hands(hands) do
    Enum.sort_by(hands, &elem(&1, 0), &compare_hands/2)
  end

  def compare_hands([], []), do: true
  def compare_hands([first | _], [second | _]) when first != second, do: first < second

  def compare_hands([_ | first_rest], [_ | second_rest]),
    do: compare_hands(first_rest, second_rest)

  def score_hands(hands) do
    hands |> Enum.with_index(1) |> Enum.map(fn {{_, bid}, rank} -> bid * rank end)
  end
end
