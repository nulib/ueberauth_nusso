# Ueberauth Strategy for Northwestern University Agentless SSO

[![Build](https://circleci.com/gh/nulib/ueberauth_nusso.svg?style=svg)](https://circleci.com/gh/nulib/ueberauth_nusso)
[![Coverage](https://coveralls.io/repos/github/nulib/ueberauth_nusso/badge.svg?branch=master)](https://coveralls.io/github/nulib/ueberauth_nusso?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/ueberauth_nusso.svg)](https://hex.pm/packages/ueberauth_nusso)

Northwestern University Agentless SSO strategy for [Ueberauth](https://github.com/ueberauth/ueberauth)

## Installation

  1. Add `ueberauth` and `ueberauth_nusso` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ueberauth, "~> 0.2"},
    {:ueberauth_nusso, "~> 0.1.0"},
  ]
end
```

  2. Ensure `ueberauth_nusso` is started before your application:

```elixir
def application do
  [applications: [:ueberauth_nusso]]
end
```

  3. Configure the NuSSO integration in `config/config.exs`:

```elixir
config :ueberauth, Ueberauth,
  providers: [nusso: {Ueberauth.Strategy.NuSSO, [
    base_url: "http://websso.example.com/",
    consumer_key: "AGENTLESS_SSO_CONSUMER_KEY",
    include_attributes: true
  ]}]
```

  4. In `AuthController` use the NuSSO strategy in your `login/4` function:

```elixir
def login(conn, _params, _current_user, _claims) do
  conn
  |> Ueberauth.Strategy.NuSSO.handle_request!
end
```

## Contributing

Issues and Pull Requests are always welcome!
