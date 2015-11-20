defmodule ExBouncer.Base do
  @moduledoc """
  A base module used by ExBouncer. Entries to specify authorized routes.

      defmodule ExBouncer.Entries do
        import ExBouncer.Base

        bouncer_for %User{role: :admin}, [
          ["api", "users", _],
          {"DELETE", ["api", "posts", _]}
        ]
      end

  This would result in dynamic methods like

        def allow?(%User{role: :admin}, ["api", "users", _]), do: true
        def allow?(%User{role: :admin}, "DELETE", ["api", "users", _]), do: true

        def visitor_allow?(%User{role: :admin}, ["api", "users", _]), do: false
        def visitor_allow?(%User{role: :admin}, "DELETE", ["api", "users", _]), do: false

  With these methods, pattern matching is done to assert if the resource is allowed or not.
  """

  @doc """
  First argument:
  It should be a resource like %User{} or %Admin{}, it can even be
  %User{role: :admin}, as bouncer_for creates method pattern matching it.

  Second argument:
  It should be an array.

  1. Each element can be an array which denotes the path_info like ["api", "posts", _] or
  2. A tuple of METHOD & path_info like {"GET", ["api", "users"]}
  """
  defmacro bouncer_for(model, allowed_routes) do
    for route <- allowed_routes do
      generate_method(model, route)
    end
  end

  defp generate_method(model, {method, final_route}) do
    quote  do
      def allow?(unquote(model), unquote(method), unquote(final_route)), do: true
      def visitor_allow?(unquote(method), unquote(final_route)), do: false
    end
  end

  defp generate_method(model, final_route) do
    quote  do
      def allow?(unquote(model), _, unquote(final_route)), do: true
      def visitor_allow?( _, unquote(final_route)), do: false
    end
  end
end
