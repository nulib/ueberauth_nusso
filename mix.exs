defmodule UeberauthOpenam.MixProject do
  use Mix.Project

  @version "0.2.4"
  @url "https://github.com/nulib/ueberauth_nusso"

  def project do
    [
      app: :ueberauth_nusso,
      version: @version,
      elixir: "~> 1.2",
      name: "Ueberauth NuSSO strategy",
      description: "Ueberauth strategy for use with Northwestern University Agentless SSO",
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
        "coveralls.html": :test
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
      {:credo, "~> 1.3.0", only: [:dev, :test]},
      {:earmark, "~> 1.2", only: [:dev, :docs]},
      {:ex_doc, "~> 0.19", only: [:dev, :docs]},
      {:excoveralls, "~> 0.12.2", only: :test},
      {:httpoison, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:mox, "~> 0.5.2", only: :test},
      {:ueberauth, ">= 0.2.0"}
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
