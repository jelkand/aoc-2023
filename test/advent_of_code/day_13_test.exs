defmodule AdventOfCode.Day13Test do
  use ExUnit.Case

  import AdventOfCode.Day13

  @input """
  #.##..##.
  ..#.##.#.
  ##......#
  ##......#
  ..#.##.#.
  ..##..##.
  #.#.##.#.

  #...##..#
  #....#..#
  ..##..###
  #####.##.
  #####.##.
  ..##..###
  #....#..#
  """

  @input2 """
  ..#..##..##
  ..#..##..##
  ##...#.#.#.
  #.#.#.#....
  .###..####.
  ##.#.....##
  ..#.#.##..#
  ...#...##..
  #########.#
  #####.###.#
  ...#...##..
  ..#.#.##..#
  ##.#.....##
  .###..####.
  #.#.#.#....
  """

  test "part1" do
    result = part1(@input2)

    assert result == 405
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
