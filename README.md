# ExBouncer :muscle:

A light weight elixir authorization module.

P.S I thought of making a lib initially, now I realize, all that is needed is
few lines of elixir code. So, feel free to copy the module

## Usage

```elixir
defmodule MyApp.Authorization.Admin do
   import ExBouncer

   allowed_paths_for %User{role: :admin}, [
     %{method: _, path_info: ["api", "users", _]},
     %{method: "DELETE", path_info: ["api", "posts", _]}
   ]
 end

defmodule MyApp.Authorization.Manager do
  import ExBouncer

  allowed_paths_for %User{role: :manager}, [
    %{method: _, path_info: ["api", "comments", _]}
  ]
end
```

```elixir
MyApp.Authorization.Admin.allow?(%User{role: :admin}, conn)
#=> true
MyApp.Authorization.Admin.allow_visitor?(conn)
#=> false
```

#### In a Plug

```elixir
defmodule MyApp.Plugs.AdminUser do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    conn.assigns[:current_user]
    |> MyApp.Authorization.Admin.allow?(conn)
    |> authorize(conn)
  end

  defp authorize(false, conn) do
    conn
    |> send_resp(401, "{\"error\":\"unauthorized\"}")
    |> halt
  end
  defp authorize(true, conn), do: conn
end
```

Begin your code :boom: Bonne Chance :metal:
