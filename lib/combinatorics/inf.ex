defmodule Combinatorics.Inf do

  # === product ===

  @doc ~S"""
  Cartesian Product of 2 Enumerables.
  (Both Enumerables should be infinite)

  ## Examples
  
    iex> Combinatorics.Inf.product([1, 2, 3], 1..3) |> Enum.to_list
    [
      {1, 1}, 
      {1, 2}, {2, 1}, 
      {1, 3}, {2, 2}, {3, 1}, 
              {2, 3}, {3, 2}, 
                      {3, 3}
    ]
  
    iex> Stream.iterate(1, &(&1+1)) |> Combinatorics.Inf.product(Stream.iterate(1, &(&1+1))) |> Enum.take(15)
    [
      {1, 1}, 
      {1, 2}, {2, 1}, 
      {1, 3}, {2, 2}, {3, 1}, 
      {1, 4}, {2, 3}, {3, 2}, {4, 1},
      {1, 5}, {2, 4}, {3, 3}, {4, 2}, {5, 1}
    ]
  """
  def product(enum1, enum2) do
    product([enum1, enum2])
  end

  @doc ~S"""
  Cartesian Product of multi Enumerables.
  (All Enumerables can be infinite)

  ## Examples
  
    iex> Combinatorics.Inf.product([1..2, 3..4, 5..6]) |> Enum.to_list
    [
      {1, 3, 5}, 
      {1, 3, 6}, {1, 4, 5}, {2, 3, 5}, 
      {1, 4, 6}, {2, 3, 6}, {2, 4, 5}, 
      {2, 4, 6}
    ]
  
    iex> Combinatorics.Inf.product([1..3, Stream.iterate(1, &(&1+1))]) |> Enum.take(15)
    [
      {1, 1}, 
      {1, 2}, {2, 1}, 
      {1, 3}, {2, 2}, {3, 1}, 
      {1, 4}, {2, 3}, {3, 2},
      {1, 5}, {2, 4}, {3, 3},
      {1, 6}, {2, 5}, {3, 4}
    ]
  """
  def product([]), do: []
  def product([it|[]]), do: Stream.map(it, &{&1})
  def product(its) when is_list(its) do
    process = &product_process/1
    Stream.unfold([process.({[], its})], &_loop(&1, process))
  end

  defp product_process({_, []}), do: nil
  defp product_process({vals, [it|xs]}) do
    it |> Stream.map(&{[&1|vals], xs})
  end

  # === combinations ===

  @doc ~S"""
  Combinations - n-length tuples, in sorted order, no repeated elements.
  The Enumerable can be infinite.

  ## Examples
  
    iex> Combinatorics.Inf.combinations(1..4, 2) |> Enum.to_list
    [
      {1, 2}, 
      {1, 3}, {2, 3}, 
      {1, 4}, {2, 4}, {3, 4}]
  
    iex> Stream.iterate(1, &(&1+1)) |> Combinatorics.Inf.combinations(3) |> Enum.take(10)
    [
      {1, 2, 3}, 
      {1, 2, 4}, {1, 3, 4}, 
      {2, 3, 4}, 
      {1, 2, 5}, {1, 3, 5}, {1, 4, 5}, 
      {2, 3, 5}, {2, 4, 5}, 
      {3, 4, 5}
    ]
  """
  def combinations(_enum, 0), do: []
  def combinations(enum, 1), do: Stream.map(enum, &{&1})
  def combinations(enum, n) when is_integer(n) and n > 1 do
    process = &combinations_process/1
    Stream.unfold([process.({[], {enum, n}})], &_loop(&1, process))
  end

  defp combinations_process({_, {_, 0}}), do: nil
  defp combinations_process({vals, {it, n}}) do
    m = n - 1
    Stream.unfold(next(it), fn
      {:next, v, next_it} -> {{[v|vals], {next_it, m}}, next(next_it)}
      _ -> nil
    end)
  end

  # === permutations ===

  @doc ~S"""
  Permutations - n-length tuples, all possible orderings, no repeated elements.
  The Enumerable can be infinite. (n cannot be omitted)

  ## Examples
  
    iex> Combinatorics.Inf.permutations(1..4, 2) |> Enum.to_list
    [
      {1, 2}, 
      {1, 3}, {2, 1}, 
      {1, 4}, {2, 3}, {3, 1}, 
              {2, 4}, {3, 2}, {4, 1}, 
                      {3, 4}, {4, 2}, 
                              {4, 3}
    ]
  
    iex> Stream.iterate(1, &(&1+1)) |> Combinatorics.Inf.permutations(3) |> Enum.take(10)
    [
      {1, 2, 3},
      {1, 2, 4}, {1, 3, 2},
      {2, 1, 3},
      {1, 2, 5}, {1, 3, 4}, {1, 4, 2}, 
      {2, 1, 4}, {2, 3, 1}, 
      {3, 1, 2}
    ]
  """
  def permutations(_enum, 0), do: []
  def permutations(enum, 1), do: Stream.map(enum, &{&1})
  def permutations(enum, n) when is_integer(n) and n > 1 do
    process = &permutations_process/1
    Stream.unfold([process.({[], {enum, n}})], &_loop(&1, process))
  end

  defp permutations_process({_, {_, 0}}), do: nil
  defp permutations_process({vals, {it, n}}) do
    m = n - 1
    Stream.unfold({[], next(it)}, fn
      {[], {:next, v, next_it}} -> {{[v|vals], {next_it, m}}, {[v], next(next_it)}}
      {es, {:next, v, next_it}} -> {{[v|vals], {{:lists.reverse(es), next_it}, m}}, {[v|es], next(next_it)}}
      _ -> nil
    end)
  end

  # === Common Private Functions ===
  defp _loop([], _), do: nil
  defp _loop([it | qs], process) do
    case next(it) do
      {:next, v = {vals, _}, rs} -> 
        case process.(v) do
          nil -> {List.to_tuple(:lists.reverse(vals)), qs ++ [rs]}
          ps -> _loop(qs ++ [ps, rs], process)
        end
      _ -> _loop(qs, process)
    end
  end

  defp reducer(v, _), do: {:suspend, v}

  defp next([]), do: :done
  defp next([x|xs]), do: {:next, x, xs}
  defp next(fun) when is_function(fun, 1) do
    case fun.({:cont, nil}) do
      {:suspended, v, next_fun} -> {:next, v, next_fun}
      _ -> :done
    end
  end
  defp next({a, b}) do
    case next(a) do
      {:next, v, as} -> {:next, v, {as, b}}
      _ -> next(b)
    end
  end
  defp next(it) do
    case Enumerable.reduce(it, {:cont, nil}, &reducer/2) do
      {:suspended, v, next_fun} -> {:next, v, next_fun}
      _ -> :done
    end
  end
end