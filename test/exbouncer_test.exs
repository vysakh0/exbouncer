defmodule User do
  defstruct role: nil
end

defmodule ExBouncer.Entries do
  import ExBouncer
  bouncer_for %User{role: :admin}, [
    ["api", "users", _],
    {"DELETE", ["api", "posts", _]}
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
    assert ExBouncer.Entries.allow?(%User{role: :admin}, conn)
    refute ExBouncer.Entries.allow?(%User{}, conn)
    refute ExBouncer.Entries.allow?(%{}, conn)
  end

  test "allow visitor to allowed routes ", %{conn: conn} do
    conn = conn |> Map.put :path_info, ["api", "posts", 123]
    assert ExBouncer.Entries.allow_visitor?(conn)

    conn = conn |> Map.put :path_info, ["api", "users", 123]
    refute ExBouncer.Entries.allow_visitor?(conn)
  end

  test "authorize specific methods" do
    conn = %{method: "DELETE", path_info: ["api", "posts", 134]}
    assert ExBouncer.Entries.allow?(%User{role: :admin}, conn)
    refute ExBouncer.Entries.allow?(%User{}, conn)

    refute ExBouncer.Entries.allow_visitor?(conn)
  end
end
