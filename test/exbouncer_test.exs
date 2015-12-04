defmodule User do
  defstruct role: nil
end

defmodule ExBouncer.Authorization.Admin do
  import ExBouncer
  @admin %User{role: :admin}
  allowed_paths_for @admin, [
    %{method: _,        path_info: ["api", "users", _]},
    %{method: "DELETE", path_info: ["api", "posts", _]}
  ]
end

defmodule ExBouncer.Authorization.Manager do
  import ExBouncer
  @manager %User{role: :manager}
  allowed_paths_for @manager, [
    %{method: _, path_info: ["api", "comments", _]}
  ]
end

defmodule ExBouncerTest do
  use ExUnit.Case
  doctest ExBouncer

  setup do
    conn = %{method: "GET", path_info: []}
    {:ok, conn: conn}
  end

  test "allow only admin user to /api/* routes ", %{conn: conn} do
    conn = conn |> Map.put :path_info, ["api", "users", 123]
    assert ExBouncer.Authorization.Admin.allow?(%User{role: :admin}, conn)
    refute ExBouncer.Authorization.Admin.allow?(%User{}, conn)
    refute ExBouncer.Authorization.Admin.allow?(%{}, conn)
  end

  test "allow visitor to allowed routes ", %{conn: conn} do
    conn = conn |> Map.put :path_info, ["api", "posts", 123]
    assert ExBouncer.Authorization.Admin.allow_visitor?(conn)

    conn = conn |> Map.put :path_info, ["api", "users", 123]
    refute ExBouncer.Authorization.Admin.allow_visitor?(conn)
  end

  test "authorize specific methods" do
    conn = %{method: "DELETE", path_info: ["api", "posts", 134]}
    assert ExBouncer.Authorization.Admin.allow?(%User{role: :admin}, conn)
    refute ExBouncer.Authorization.Admin.allow?(%User{}, conn)

    refute ExBouncer.Authorization.Admin.allow_visitor?(conn)
  end

  test "multiple allowed_paths_for" do
    conn = %{method: "DELETE", path_info: ["api", "comments", 134]}
    assert ExBouncer.Authorization.Manager.allow?(%User{role: :manager}, conn)
  end
end
