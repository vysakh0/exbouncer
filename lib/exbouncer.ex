defmodule ExBouncer do
  @moduledoc """
  A ExBouncer.Entries module needs to be defined with authorized routes.

      defmodule ExBouncer.Entries do
        import ExBouncer.Base

        exbouncer_for %User{role: :admin}, [
          ["api", "users", _]
        ]
      end

  This means, a %User{role: :admin} can visit /api/users/* route.

  So, just after you set your current_user in your plug, you could invoke,

        ExBouncer.allow_resource?(user, conn)
        #=> true

  This would give true/false based on `ExBouncer.Entries` made.

  Since this route (/api/users/*) is allowed for %User{role: :admin}, it won't be allowed for any others, including visitors. In case if you want to check if the route is accessible to visitors you could do

    ExBouncer.allow_visitor?(conn)
    #=> false

  """
  alias ExBouncer.Entries

  @doc """
  If a `exbouncer_for` entry for a particular resource say, %User{}  is made in `ExBouncer.Entries` (see h ExBouncer), then we can be assured that other resource will not allowed :)

      ExBouncer.allow_resource?(conn)
      #=> false
  """
  def allow_resource?(resource, conn) do
    resource_allowed?(resource, conn.method, conn.path_info)
  end

  @doc """
  For every `exbouncer_for` for a particular resource (say %User{}) is made, then for that route `allow_visitor?\1` would be false.

      ExBouncer.allow_visitor?(conn)
      #=> false
  """
  def allow_visitor?(conn) do
    visitor_allowed?(conn.method, conn.path_info)
  end

  defp resource_allowed?(resource, method, path) do
    try do
      Entries.allow?(resource, method, path)
    rescue
      _ -> false
    end
  end

  defp visitor_allowed?(method, path) do
    try do
      Entries.visitor_allow?(method, path)
    rescue
      _ -> true
    end
  end

end
