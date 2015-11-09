defmodule InfTest do
  use ExUnit.Case
  doctest Combinatorics.Inf

  test "Combinatorics.Inf.combinations(enum, 0)" do
    assert (Combinatorics.Inf.combinations(1..4, 0) |> Enum.to_list) == []
  end

  test "Combinatorics.Inf.combinations(enum, 1)" do
    assert (Combinatorics.Inf.combinations(1..4, 1) |> Enum.to_list) == [{1}, {2}, {3}, {4}]
  end

  test "Combinatorics.Inf.combinations(enum, n) when n == Enum.count(enum)" do
    assert (Combinatorics.Inf.combinations(1..4, 4) |> Enum.to_list) == [{1, 2, 3, 4}]
  end

  test "Combinatorics.Inf.combinations(enum, n) when n > Enum.count(enum)" do
    assert (Combinatorics.Inf.combinations(1..4, 5) |> Enum.to_list) == []
  end

  test "Combinatorics.Inf.permutations(range)" do
    assert (Combinatorics.Inf.permutations(3..1, 3) |> Enum.to_list) == 
      [
        {3, 2, 1}, 
        {3, 1, 2}, {2, 3, 1}, 
                   {2, 1, 3}, {1, 3, 2}, 
                              {1, 2, 3}
      ]
  end

  test "Combinatorics.Inf.permutations(enum, 0)" do
    assert (Combinatorics.Inf.permutations(1..4, 0) |> Enum.to_list) == []
  end

  test "Combinatorics.Inf.permutations(enum, 1)" do
    assert (Combinatorics.Inf.permutations(1..4, 1) |> Enum.to_list) == [{1}, {2}, {3}, {4}]
  end

  test "Combinatorics.Inf.permutations(enum, n) when n > Enum.count(enum)" do
    assert (Combinatorics.Inf.permutations(1..4, 5) |> Enum.to_list) == []
  end
end