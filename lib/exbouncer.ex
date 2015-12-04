defmodule ExBouncer do
  defmacro allowed_paths_for(model, allowed_routes) do
    for route <- allowed_routes do
      generate_methods(model, route)
    end
    ++
    [fallback_methods]
  end

  defp generate_methods(model, route) do
    quote  do
      def allow?(unquote(model), unquote(route)), do: true
      def allow_visitor?(unquote(route)), do: false
    end
  end

  defp fallback_methods do
    quote do
      def allow?(_, _), do: false
      def allow_visitor?(_), do: true
    end
  end
end
