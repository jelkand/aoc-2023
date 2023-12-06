defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  @input """
  Time:      7  15   30
  Distance:  9  40  200
  """

  test "part1" do
    result = part1(@input)

    assert result == 288
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
