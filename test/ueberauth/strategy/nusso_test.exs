defmodule Ueberauth.Strategy.NuSSOTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Ueberauth.Strategy.NuSSO
  import Ueberauth.NuSSO.TestHelpers

  setup do
    stub_endpoint()
    :ok
  end

  test "redirect callback redirects to login url" do
    conn = conn(:get, "/login") |> NuSSO.handle_request!()
    assert conn.status == 302
  end

  test "login callback without token shows an error" do
    conn = %Plug.Conn{cookies: %{}} |> NuSSO.handle_callback!()
    assert conn.assigns |> Map.has_key?(:ueberauth_failure)
  end

  test "error callback" do
    conn = %Plug.Conn{cookies: %{"nusso" => "error-sso-token"}} |> NuSSO.handle_callback!()

    assert conn
           |> dig([:assigns, :ueberauth_failure, :errors, 0, :message]) ==
             ~s'"Server Error"'
  end

  test "invalid callback" do
    conn = %Plug.Conn{cookies: %{"nusso" => "bad-sso-token"}} |> NuSSO.handle_callback!()

    assert conn
           |> dig([:assigns, :ueberauth_failure, :errors, 0, :message]) ==
             "Missing, invalid, or expired SSO Token"
  end

  describe "valid callback" do
    setup do
      {:ok, conn: %Plug.Conn{cookies: %{"nusso" => "test-sso-token"}} |> NuSSO.handle_callback!()}
    end

    test "returns user details", %{conn: conn} do
      with user <- conn.private.nusso_user do
        assert user.mail == "archie.charles@example.edu"
        assert user.sn == "Charles"
      end
    end

    test "extracts UID", %{conn: conn} do
      assert conn |> NuSSO.uid() == "abc123"
    end

    test "generates an info struct", %{conn: conn} do
      with info <- conn |> NuSSO.info() do
        assert info.email == "archie.charles@example.edu"
        assert info.name == "Archie B. Charles"
        assert info.nickname == "abc123"
      end
    end

    test "generates a raw info struct", %{conn: conn} do
      with user <- NuSSO.extra(conn).raw_info.user do
        assert user == conn.private.nusso_user
      end
    end
  end
end
