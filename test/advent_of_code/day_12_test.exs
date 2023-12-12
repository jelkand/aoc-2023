defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  @input """
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
  """

  test "part1" do
    result = part1(@input)

    assert result == 21
  end

  @tag :skip
  test "part2" do
    result = part2(@input)

    assert result == 525_152
  end
end
