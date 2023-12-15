defmodule AdventOfCode.Day15Test do
  use ExUnit.Case

  import AdventOfCode.Day15

  @input "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
  test "part1" do
    result = part1(@input)
    assert result == 1320
  end

  test "part2" do
    result = part2(@input)

    assert result == 145
  end
end
