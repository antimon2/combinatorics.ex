defmodule Combinatorics.Util do
  # no doc

  # for List
  def _next([]), do: :done
  def _next([x|xs]), do: {:next, x, xs}
  # for Range
  def _next(a..b) when is_integer(a) and is_integer(b) do
    _range_next(a, b)
  end
  # for Function by `Enumerable.reduce`
  def _next(fun) when is_function(fun, 1) do
    case fun.({:cont, nil}) do
      {:suspended, v, next_fun} -> {:next, v, next_fun}
      _ -> :done
    end
  end
  # for Tuple of 2 Nextables
  def _next({a, b}) do
    case _next(a) do
      {:next, v, as} -> {:next, v, {as, b}}
      _ -> _next(b)
    end
  end
  # for Enumerable
  def _next(it) do
    case Enumerable.reduce(it, {:cont, nil}, &_reducer/2) do
      {:suspended, v, next_fun} -> {:next, v, next_fun}
      _ -> :done
    end
  end

  # for Range (sub-function)
  defp _range_next(a, b) when a < b do
    {:next, a, (a+1)..b}
  end
  defp _range_next(a, b) when a > b do
    {:next, a, (a-1)..b}
  end
  defp _range_next(a, b) when a == b do
    {:next, a, []}
  end
  # for Enumerable (sub-function)
  defp _reducer(v, _), do: {:suspend, v}
end