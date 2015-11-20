# ExBouncer :muscle:

An authorization library :cop: in Elixir :sake: for Plug applications that restricts what resources the current user/admin or any role is allowed to access.

Use this in any of your plug module, where you fetch the current user or admin. You could then halt the chain, even before it reaches the controller.

## Installation

**Dependencies**: Make sure you have Erlang 18+ version installed and Elixir 1.x version.

  1. Add exbouncer to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:exbouncer, "~> 0.0.1"}]
    end
    ```

  2. Ensure exbouncer is started before your application:

    ```elixir
    def application do
      [applications: [:exbouncer]]
    end
    ```

  3. Define a `ExBouncer.Entries` module with authorization logic

    ```elixir
    defmodule ExBouncer.Entries do
      import ExBouncer.Base

      bouncer_for %User{role: :admin}, [
        ["api", "users", _],
        {"DELETE", ["api", "posts", _]}
      ]
    end
    ```

    **First argument:**

    It should be a resource like %User{} or %Admin{}, it can even be
    %User{role: :admin}, as bouncer_for creates method pattern matching it.

    **Second argument:**

    It should be an array.

    - Each element can be an array which denotes the path_info

    ```
    ["api", "posts", _]
    ```
    will match the any `http` method (since nothing is specified explicitly). And `_` would mean it would match `/api/posts/*` such as these

    ```
    GET /api/posts/1
    GET /api/posts/latest
    POST /api/posts
    DELETE /api/posts/1
    ```

    -  Or method can be explicitly specified in a `tuple` of METHOD & path_info like

    ```
    {"GET", ["api", "users", _]}
    ```
    will match routes such as these
    ```
    GET /api/posts/1
    GET /api/posts/latest
    ```

## Usage

In your plug, once you identify the appropriate resource (say: a current user), you can pass it to check if they are allowed to visit the route.


```elixir
ExBouncer.allow_resource?(%User{role: :admin}, conn)
#=> true
```

```elixir
ExBouncer.allow_visitor?(conn)
#=> false
```

For every `bouncer_for` for a particular resource (say %User{}) is made, then for that route `allow_visitor?\1` would be false.

Begin your code :boom: Bonne Chance :metal:
