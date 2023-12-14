defmodule AdventOfCode.Day14Test do
  use ExUnit.Case

  import AdventOfCode.Day14

  @input """
  O....#....
  O.OO#....#
  .....##...
  OO.#O....O
  .O.....O#.
  O.#..O.#.#
  ..O..#O..O
  .......O..
  #....###..
  #OO..#....
  """

  @tag :skip
  test "part1" do
    result = part1(@input)

    assert result == 136
  end

  test "part2" do
    result = part2(@input)

    assert result == 64
  end
end
