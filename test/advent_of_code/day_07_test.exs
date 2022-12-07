defmodule AdventOfCode.Day07Test do
  use ExUnit.Case

  import AdventOfCode.Day07

  # test "foo" do
  #   input = %{"/" => %{files: [{"i", 584}], files_size: 584}}

  #   result = dirs_to_sizes(input)

  #   assert result ==
  #            %{"/" => %{files: [{"i", 584}], files_size: 584, size: 584}}
  # end

  # test "foo2" do
  #   input = %{
  #     "a" => %{
  #       :files => [{"f", 29116}, {"g", 2557}, {"h.lst", 62596}],
  #       :files_size => 94269,
  #       "e" => %{files: [{"i", 584}], files_size: 584}
  #     }
  #   }

  #   result = dirs_to_sizes(input)

  #   assert result == %{
  #            "a" => %{
  #              :files => [{"f", 29116}, {"g", 2557}, {"h.lst", 62596}],
  #              :files_size => 94269,
  #              "e" => %{files: [{"i", 584}], files_size: 584, size: 584},
  #              :size => 94853
  #            }
  #          }
  # end

  test "part1" do
    input = """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    """

    # dir e

    # 29116 f
    # 2557 g
    # 62596 h.lst
    # $ cd e
    # $ ls
    # 584 i
    # $ cd ..
    # $ cd ..
    # $ cd d
    # $ ls
    # 4060174 j
    # 8033020 d.log
    # 5626152 d.ext
    # 7214296 k

    result = part1(input)

    assert result == 95437
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
