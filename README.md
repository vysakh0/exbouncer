# ExBouncer :muscle:

A light weight elixir authorization library.

Use this in any of your plug module, where you fetch the current user or any resource.
You could then halt the chain, even before it reaches the controller.

## Installation

**Dependencies**: Make sure you have Erlang 18+ version installed and Elixir 1.x version.

  1. Add exbouncer to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:exbouncer, "~> 0.0.1"}]
    end
    ```

  2. Define a module that imports `ExBouncer` and define authorization logic using `bouncer_for`
  macro.

    ```elixir
    defmodule MyApp.AuthorizedRoutes do
      import ExBouncer

      bouncer_for %User{role: :admin}, [
        ["api", "users", _],
        {"DELETE", ["api", "posts", _]}
      ]
    end
    ```

   **First argument:**

   It should be a resource like `%User{}` or `%Admin{}`, it can even be
   `%User{role: :admin}`, as `bouncer_for` creates a method pattern matching it.

   **Second argument:**

   It should be a list and each element can be a list or a tuple.

   - When an element is a list, it denotes the `path_info`

   ```
   ["api", "posts", _]
   ```
   will match the any `http` method (since nothing is specified explicitly).
   And `_` would mean it would match `/api/posts/*` such as these

   ```
   GET /api/posts/1
   GET /api/posts/latest
   POST /api/posts
   DELETE /api/posts/1
   ```

   - Or method can be explicitly specified in a `tuple` of `METHOD` & `path_info` like

   ```
   {"GET", ["api", "users", _]}
   ```

   will match routes such as these
   ```
   GET /api/users/1
   GET /api/users/latest
    ```

## Usage

In your plug, once you identify the appropriate resource, pass it to check if
they are allowed to visit the route.


```elixir
MyApp.AuthorizedRoutes.allow?(%User{role: :admin}, conn)
#=> true
```

For every `bouncer_for` for a particular resource (say %User{}) is made,
then for that route `allow_visitor?\1` would be false.

```elixir
MyApp.AuthorizedRoutes.allow_visitor?(conn)
#=> false
```

#### In a Plug

```elixir
defmodule MyApp.Plugs.AdminUser do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    conn.assigns[:current_user]
    |> MyApp.AuthorizedRoutes.allow?(conn)
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
