defmodule Combinatorics do

  # === product ===

  @doc ~S"""
  Cartesian Product of 2 Enumerables.
  (At least 2nd Enumerable should be finite)

  ## Examples
  
    iex> Combinatorics.product([1, 2, 3], 1..3) |> Enum.to_list
    [{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}]
  
    iex> Stream.iterate(1, &(&1+1)) |> Combinatorics.product(1..3) |> Enum.take(10)
    [{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}, {4, 1}]
  """
  def product(enum1, enum2) do
    product([enum1, enum2])
  end

  @doc ~S"""
  Cartesian Product of multi Enumerables.
  (At least last Enumerable should be finite)

  ## Examples
  
    iex> Combinatorics.product([1..2, 3..4, 5..6]) |> Enum.to_list
    [{1, 3, 5}, {1, 3, 6}, {1, 4, 5}, {1, 4, 6}, {2, 3, 5}, {2, 3, 6}, {2, 4, 5}, {2, 4, 6}]
  
    iex> Combinatorics.product([Stream.iterate(1, &(&1+1)), 1..3]) |> Enum.take(10)
    [{1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}, {4, 1}]
  """
  def product([]), do: []
  def product([it|[]]), do: Stream.map(it, &{&1})
  def product(its) when is_list(its) do
    funs = its |> Enum.map(fn it -> 
      # case Enumerable.reduce(it, {:suspend, nil}, &reducer/2) do
      #   {:suspended, _, fun} -> fun
      # end 
      Enumerable.reduce(it, {:suspend, nil}, &reducer/2) |> elem(2)
    end)
    &do_product({funs, [], funs, [], []}, &1, &2)
  end

  defp do_product(_, {:halt, term}, _fun), do: {:halted, term}
  defp do_product(v, {:suspend, term}, fun) do
    {:suspended, term, &do_product(v, &1, fun)}
  end
  defp do_product({[], [f|fs], [], [e|es], vals = [_|vs]}, {:cont, term}, fun) do
    do_product({[f], fs, [e], es, vs}, fun.(List.to_tuple(:lists.reverse(vals)), term), fun)
  end
  defp do_product({[x|xs], [], [e|es], [], []}, acc = {:cont, term}, fun) do
    case e.({:cont, nil}) do
      {:suspended, v, next_e} -> do_product({xs, [x], es, [next_e], [v]}, acc, fun)
      _ -> {:done, term}
    end
  end
  defp do_product({xss = [x|xs], yss = [y|ys], [e|es], zss = [z|zs], vals = [_|vs]}, acc = {:cont, _}, fun) do
    case e.({:cont, nil}) do
      {:suspended, v, next_e} -> do_product({xs, [x|yss], es, [next_e|zss], [v|vals]}, acc, fun)
      _ -> do_product({[y|xss], ys, [z|[x|es]], zs, vs}, acc, fun)
    end
  end

  # === combinations ===

  @doc ~S"""
  Combinations - n-length tuples, in sorted order, no repeated elements.

  ## Examples
  
    iex> Combinatorics.combinations(1..4, 2) |> Enum.to_list
    [{1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, {3, 4}]
  
    iex> Combinatorics.combinations(1..4, 3) |> Enum.to_list
    [{1, 2, 3}, {1, 2, 4}, {1, 3, 4}, {2, 3, 4}]
  """
  def combinations(_enum, 0), do: []
  def combinations(enum, 1), do: Stream.map(enum, &{&1})
  def combinations(enum, n) when is_integer(n) and n > 1 do
    case Enumerable.reduce(enum, {:cont, nil}, &reducer/2) do
      {:halted, _} -> []
      {:done, _} -> []
      {:suspended, v, fun} -> &do_combinations({[fun], [v], :next, n - 1}, &1, &2)
    end
  end

  defp do_combinations(_, {:halt, term}, _fun), do: {:halted, term}
  defp do_combinations(v, {:suspend, term}, fun) do
    {:suspended, term, &do_combinations(v, &1, fun)}
  end
  defp do_combinations({[], _, _, _}, {:cont, term}, _), do: {:done, term}
  defp do_combinations({fs, vals, _, 0}, {:cont, term}, fun) do
    do_combinations({fs, vals, :back, 1}, fun.(List.to_tuple(:lists.reverse(vals)), term), fun)
  end
  defp do_combinations({funs = [f|fs], vals = [_|vs], :next, n}, acc = {:cont, _}, fun) do
    case f.({:cont, nil}) do
      {:suspended, v, next_f} -> do_combinations({[next_f|funs], [v|vals], :next, n - 1}, acc, fun)
      _ -> do_combinations({fs, vs, :back, n + 2}, acc, fun)
    end
  end
  defp do_combinations({[f|fs], [_|vs], :back, n}, acc = {:cont, _}, fun) do
    case f.({:cont, nil}) do
      {:suspended, v, next_f} -> do_combinations({[next_f|fs], [v|vs], :next, n - 1}, acc, fun)
      _ -> do_combinations({fs, vs, :back, n + 1}, acc, fun)
    end
  end

  # === Common Private Functions ===
  defp reducer(v, _), do: {:suspend, v}
end