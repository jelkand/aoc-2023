defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  import AdventOfCode.Day10

  test "part1" do
    input1 = """
    .....
    .S-7.
    .|.|.
    .L-J.
    .....
    """

    result1 = part1(input1)

    assert result1 == 4

    input2 = """
    ..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...
    """

    result2 = part1(input2)

    assert result2 == 8
  end

  test "part2" do
    input1 = """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ........... 
    """

    result = part2(input1)

    assert result == 4
  end
end
