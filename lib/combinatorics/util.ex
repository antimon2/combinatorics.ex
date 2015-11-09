defmodule Combinatorics.Util do
  # no doc
  def _next([]), do: :done
  def _next([x|xs]), do: {:next, x, xs}
  def _next(fun) when is_function(fun, 1) do
    case fun.({:cont, nil}) do
      {:suspended, v, next_fun} -> {:next, v, next_fun}
      _ -> :done
    end
  end
  def _next({a, b}) do
    case _next(a) do
      {:next, v, as} -> {:next, v, {as, b}}
      _ -> _next(b)
    end
  end
  def _next(it) do
    case Enumerable.reduce(it, {:cont, nil}, &_reducer/2) do
      {:suspended, v, next_fun} -> {:next, v, next_fun}
      _ -> :done
    end
  end

  defp _reducer(v, _), do: {:suspend, v}
end