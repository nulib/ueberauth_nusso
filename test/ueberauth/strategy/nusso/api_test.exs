defmodule Ueberauth.Strategy.NuSSO.APITest do
  use ExUnit.Case, async: true
  alias Ueberauth.Strategy.NuSSO.API
  import Ueberauth.NuSSO.TestHelpers

  describe "API" do
    setup tags do
      with old_config <- Application.get_env(:ueberauth, Ueberauth),
           {provider, settings} <- old_config |> get_in([:providers, :nusso]) do
        if tags[:config] do
          Application.put_env(
            :ueberauth,
            Ueberauth,
            old_config
            |> put_in([:providers, :nusso], {provider, settings |> Keyword.merge(tags[:config])})
          )
        end

        on_exit(fn ->
          Application.put_env(:ueberauth, Ueberauth, old_config)
        end)
      end

      stub_endpoint()
      :ok
    end

    test "login_url/0" do
      with uri <- API.login_url("http://example.edu/") |> URI.parse(),
           params <- URI.decode_query(uri.fragment) do
        assert uri.host == "test-nusso.example.edu"
        assert uri.path == "/nusso/XUI/"
        assert params |> Map.get("goto") == "https://example.edu/"
      end

      assert_received({:header, {"apikey", "test-consumer-key"}})
      assert_received({:header, {"goto", "http://example.edu/"}})
    end

    @tag config: [include_attributes: false]
    test "token validation without attributes" do
      with {:ok, user} <- API.redeem_token("test-sso-token") do
        assert user.uid == "abc123"
        refute user |> Map.has_key?(:displayName)
      end

      assert_received({:header, {"apikey", "test-consumer-key"}})
      assert_received({:header, {"webssotoken", "test-sso-token"}})
    end

    test "token validation with attributes" do
      with {:ok, user} <- API.redeem_token("test-sso-token") do
        assert user.uid == "abc123"
        assert user.displayName == "Archie B. Charles"
        refute user |> Map.has_key?(:eduPersonNickname)
      end

      assert_received({:header, {"apikey", "test-consumer-key"}})
      assert_received({:header, {"webssotoken", "test-sso-token"}})
    end

    test "bad token" do
      with {:error, response} <- API.redeem_token("bad-sso-token") do
        assert response.message == "Missing, invalid, or expired SSO Token"
      end
    end
  end
end
