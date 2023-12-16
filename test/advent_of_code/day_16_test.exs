defmodule AdventOfCode.Day16Test do
  use ExUnit.Case

  import AdventOfCode.Day16

  @input """
  .|...\\....
  |.-.\\.....
  .....|-...
  ........|.
  ..........
  .........\\
  ..../.\\\\..
  .-.-/..|..
  .|....-|.\\
  ..//.|....
  """
  test "part1" do
    result = part1(@input)

    assert result == 46
  end

  test "part2" do
    result = part2(@input)

    assert result == 51
  end
end
