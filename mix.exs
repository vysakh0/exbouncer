defmodule ExBouncer.Mixfile do
  use Mix.Project

  def project do
    [app: :exbouncer,
      version: "0.0.1",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: [
        maintainers: ["Vysakh Sreenivasan"],
        licenses: ["MIT"],
        links: %{github: "https://github.com/vysakh0/exbouncer"}
      ],
      description: """
      An authorization library in Elixir for Plug applications that restricts what resources the current user/admin or any role is allowed to access,
      """,
    deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end
