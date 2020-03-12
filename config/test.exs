use Mix.Config

config :ueberauth, Ueberauth,
  providers: [
    nusso:
      {Ueberauth.Strategy.NuSSO,
       [
         base_url: "https://test.example.edu/agentless-websso/",
         consumer_key: "test-consumer-key",
         http_client: HTTPMock,
         include_attributes: true
       ]}
  ]
