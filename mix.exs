defmodule UeberauthOpenam.MixProject do
  use Mix.Project

  @version "2.0.0"
  @url "https://github.com/nulib/ueberauth_nusso"

  def project do
    [
      app: :ueberauth_nusso,
      version: @version,
      elixir: "~> 1.12",
      name: "Ueberauth NuSSO strategy",
      description: "Ueberauth strategy for use with Northwestern University Agentless SSO",
      xref: [exclude: [Jason]],
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @url,
      homepage_url: @url,
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        credo: :test
      ],
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:ueberauth],
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.3", only: :test},
      {:earmark, "~> 1.2", only: :docs},
      {:ex_doc, "~> 0.19", only: :docs},
      {:excoveralls, "~> 0.12", only: :test},
      {:httpoison, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:mox, ">= 1.0.0", only: :test},
      {:ueberauth, "~> 0.10.0 and <= 0.10.5 or >= 0.10.7"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Michael B. Klein"],
      licenses: ["MIT"],
      links: %{GitHub: @url}
    ]
  end
end
