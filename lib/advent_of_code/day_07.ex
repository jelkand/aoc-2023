defmodule AdventOfCode.Day07 do
  def part1(args) do
    args
    |> parse_input()
    |> classify_hands()
    |> sort_hands()
    |> score_hands()
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_input(:part_2)
    |> classify_hands(:part_2)
    |> sort_hands()
    |> score_hands()
    |> Enum.sum()
  end

  def parse_input(input, flag \\ :part_1) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [hand, bid] ->
      {String.split(hand, "", trim: true)
       |> replace_face_cards(flag)
       |> Enum.map(&String.to_integer/1), String.to_integer(bid)}
    end)
  end

  def replace_face_cards(hand, flag) do
    Enum.map(hand, &maybe_replace_card(&1, flag))
  end

  def maybe_replace_card(card, flag \\ nil)
  def maybe_replace_card("K", _), do: "13"
  def maybe_replace_card("Q", _), do: "12"
  def maybe_replace_card("J", :part_2), do: "1"
  def maybe_replace_card("J", _), do: "11"
  def maybe_replace_card("T", _), do: "10"
  def maybe_replace_card("A", _), do: "14"
  def maybe_replace_card(card, _), do: card

  def classify_hands(hands, flag \\ nil) do
    hands
    |> Enum.map(&preprocess_hand(&1, flag))
  end

  def preprocess_hand({hand, bid}, flag \\ nil) do
    type =
      hand
      |> Enum.group_by(fn card -> card end)
      |> maybe_handle_jokers(flag)
      |> Map.values()
      |> Enum.map(fn group -> length(group) end)
      |> Enum.sort(:desc)
      |> classify_hand()

    {[type | hand], bid}
  end

  def maybe_handle_jokers(grouped, :part_2) do
    jokers = Map.get(grouped, 1, [])

    no_jokers = Map.delete(grouped, 1)

    most_common_card =
      no_jokers
      |> Enum.sort_by(fn {_k, v} ->
        length(v)
      end)
      |> Enum.reverse()
      |> List.first()

    case most_common_card do
      # all jokers
      nil -> Map.put(no_jokers, 1, jokers)
      {card, _instances} -> Map.update!(no_jokers, card, &(&1 ++ jokers))
    end
  end

  def maybe_handle_jokers(grouped, _), do: grouped

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
