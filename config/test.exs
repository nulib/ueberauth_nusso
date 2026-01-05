import Config

config :ueberauth, Ueberauth, providers: [nusso: {Ueberauth.Strategy.NuSSO, []}]

config :ueberauth, Ueberauth.Strategy.NuSSO,
  base_url: "https://test.example.edu/",
  consumer_key: "test-consumer-key",
  include_attributes: true
