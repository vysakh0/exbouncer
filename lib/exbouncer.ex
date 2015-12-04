defmodule ExBouncer do
  @moduledoc """
  A module which imports `ExBouncer` needs to be defined with authorized routes.

      defmodule MyApp.AuthorizedRoutes do
        import ExBouncer

        bouncer_for %User{role: :admin}, [
          ["api", "users", _]
        ]
      end

  This would result in dynamic methods like

      def allow?(%User{role: :admin}, %{method: _, path_info: ["api", "users", _]}), do: true
      def allow?(%User{role: :admin}, %{method: "DELETE", path_info: ["api", "users", _]}), do: true

      def allow_visitor?(%User{role: :admin}, %{method: _, path_info ["api", "users", _]}), do: false
      def allow_visitor?(%User{role: :admin}, %{method: "DELETE", path_info: ["api", "users", _]}), do: false


  With these methods, pattern matching is done to assert if the resource is allowed or not.
  This means, a %User{role: :admin} can visit /api/users/* route.

  So, just after you set your current_user in your plug, you could invoke,

        MyApp.AuthorizedRoutes.allow?(user, conn)
        #=> true

  This would give true/false based on authorized entry you made.

  Since this route (`/api/users/*`) is allowed for `%User{role: :admin}`,
  it won't be allowed for any others, including visitors.
  In case if you want to check if the route is accessible to visitors you could do

        MyApp.AuthorizedRoutes.allow_visitor?(conn)
        #=> false
  """

  @doc """
  After importing `ExBouncer` in your Authorization module, the various allowed
  paths for a resource needs to be defined using `bouncer_for` macro.

  First argument:
    It should be a resource like %User{} or %Admin{}, it can even be
  %User{role: :admin}, as bouncer_for creates method pattern matching it.

  Second argument:
    It should be a list and each element can be a list or a tuple.

    1. Each element can be a list which denotes the path_info like ["api", "posts", _] or
    2. A tuple of METHOD & path_info like {"GET", ["api", "users"]}
  """
  defmacro bouncer_for(model, allowed_routes) do
    for route <- allowed_routes do
      generate_method(model, route)
    end
    ++
    [default_methods]
  end

  defp generate_method(model, {method, final_route}) do
    quote  do
      def allow?(unquote(model), %{method: unquote(method), path_info: unquote(final_route)}), do: true
      def allow_visitor?(%{method: unquote(method), path_info: unquote(final_route)}), do: false
    end
  end

  defp generate_method(model, final_route) do
    quote  do
      def allow?(unquote(model), %{method: _, path_info: unquote(final_route)}), do: true
      def allow_visitor?(%{method: _, path_info: unquote(final_route)}), do: false
    end
  end

  defp default_methods do
    quote do
      def allow?(_, _), do: false
      def allow?(_), do: false
      def allow_visitor?(_, _), do: true
      def allow_visitor?(_), do: true
    end
  end
end
