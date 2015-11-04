defmodule CombinatoricsTest do
  use ExUnit.Case
  doctest Combinatorics

  test "Combinatorics.combinations(enum, 0)" do
    assert (Combinatorics.combinations(1..4, 0) |> Enum.to_list) == []
  end

  test "Combinatorics.combinations(enum, 1)" do
    assert (Combinatorics.combinations(1..4, 1) |> Enum.to_list) == [{1}, {2}, {3}, {4}]
  end

  test "Combinatorics.combinations(enum, n) when n == Enum.count(enum)" do
    assert (Combinatorics.combinations(1..4, 4) |> Enum.to_list) == [{1, 2, 3, 4}]
  end

  test "Combinatorics.combinations(enum, n) when n > Enum.count(enum)" do
    assert (Combinatorics.combinations(1..4, 5) |> Enum.to_list) == []
  end
end