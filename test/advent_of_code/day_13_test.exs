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

  @tag :skip
  test "part1" do
    result = part1(@input)

    assert result == 405
  end

  test "part2" do
    result = part2(@input)

    assert result == 400
  end
end
