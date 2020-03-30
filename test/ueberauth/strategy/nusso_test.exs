defmodule Ueberauth.Strategy.NuSSOTest do
  use ExUnit.Case
  use Plug.Test
  alias Ueberauth.Strategy.NuSSO
  import Ueberauth.NuSSO.TestHelpers

  setup do
    stub_endpoint()
    :ok
  end

  describe "request phase" do
    setup tags do
      conn =
        conn(:get, "/login")
        |> put_req_header("referer", tags[:referer])
        |> init_test_session(%{})
        |> NuSSO.handle_request!()

      {:ok, %{conn: conn}}
    end

    @tag referer: "https://referer.example.edu"
    test "redirect callback redirects to login url", %{conn: conn} do
      assert conn.status == 302
    end

    @tag referer: "https://referer.example.edu"
    test "https referer is passed through", %{conn: conn} do
      assert conn |> get_session("nussoReferer") == "https://referer.example.edu"
    end

    @tag referer: "http://referer.example.edu"
    test "http referer is converted to https", %{conn: conn} do
      assert conn |> get_session("nussoReferer") == "https://referer.example.edu"
    end
  end

  test "login callback without token shows an error" do
    conn = %Plug.Conn{cookies: %{}} |> init_test_session(%{}) |> NuSSO.handle_callback!()
    assert conn.assigns |> Map.has_key?(:ueberauth_failure)
  end

  test "error callback" do
    conn =
      %Plug.Conn{cookies: %{"nusso" => "error-sso-token"}}
      |> init_test_session(%{})
      |> NuSSO.handle_callback!()

    assert conn
           |> dig([:assigns, :ueberauth_failure, :errors, 0, :message]) ==
             ~s'"Server Error"'
  end

  test "invalid callback" do
    conn =
      %Plug.Conn{cookies: %{"nusso" => "bad-sso-token"}}
      |> init_test_session(%{})
      |> NuSSO.handle_callback!()

    assert conn
           |> dig([:assigns, :ueberauth_failure, :errors, 0, :message]) ==
             "Missing, invalid, or expired SSO Token"
  end

  describe "valid callback" do
    setup do
      {:ok,
       conn:
         %Plug.Conn{cookies: %{"nusso" => "test-sso-token"}}
         |> init_test_session(%{nussoReferer: "https://referer.example.edu"})
         |> NuSSO.handle_callback!()}
    end

    test "returns user details", %{conn: conn} do
      assert user = conn.private.nusso_user
      assert user.mail == "archie.charles@example.edu"
      assert user.sn == "Charles"
    end

    test "extracts UID", %{conn: conn} do
      assert conn |> NuSSO.uid() == "abc123"
    end

    test "generates an info struct", %{conn: conn} do
      assert info = conn |> NuSSO.info()
      assert info.email == "archie.charles@example.edu"
      assert info.name == "Archie B. Charles"
      assert info.nickname == "abc123"
    end

    test "generates a raw info struct", %{conn: conn} do
      assert user = NuSSO.extra(conn).raw_info.user
      assert user == conn.private.nusso_user
    end

    test "resets original referer", %{conn: conn} do
      assert conn |> get_req_header("referer") == ["https://referer.example.edu"]
    end
  end
end
