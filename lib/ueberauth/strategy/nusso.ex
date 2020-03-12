defmodule Ueberauth.Strategy.NuSSO do
  @moduledoc """
  NuSSO Strategy for Überauth. Redirects the user to an NuSSO
  login page and verifies the auth token the NuSSO server returns
  after a successful login.
  The login flow looks like this:
  1. User is redirected to the NuSSO server's login page by
    `Ueberauth.Strategy.NuSSO.handle_request!`
  2. User signs in to the NuSSO server.
  3. NuSSO server redirects back to the Elixir application, sending
     an auth token as an HTTP Cookie header.
  4. This auth token is validated by this Überauth NuSSO strategy,
     fetching the user's information at the same time.
  5. User can proceed to use the Elixir application.
  """

  use Ueberauth.Strategy

  alias Ueberauth.Auth.{Extra, Info}
  alias Ueberauth.Strategy.NuSSO

  @doc """
  Ueberauth `request` handler. Redirects to the NuSSO server's login page.
  """
  def handle_request!(conn) do
    conn
    |> redirect!(redirect_url(conn))
  end

  @doc """
  Ueberauth after login callback with a valid NuSSO Cookie.
  """
  def handle_callback!(%Plug.Conn{} = conn) do
    handle_token(conn, conn.cookies[NuSSO.API.sso_cookie()])
  end

  @doc "Ueberauth UID callback."
  def uid(conn), do: conn.private.nusso_user.uid

  @doc """
  Ueberauth extra information callback. Returns all attributes the NuSSO
  server returned about the user that authenticated.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        user: conn.private.nusso_user
      }
    }
  end

  @doc """
  Ueberauth user information.
  """
  def info(conn) do
    user = conn.private.nusso_user

    %Info{
      email: user.mail,
      name: Enum.join([user.givenName, user.sn], " "),
      nickname: user.uid
    }
  end

  defp redirect_url(conn) do
    callback_url(conn)
    |> NuSSO.API.login_url()
  end

  defp handle_token(conn, nil) do
    conn
    |> set_errors!([error("missing_sso_cookie", "No NuSSO SSO cookie received")])
  end

  defp handle_token(conn, token) do
    token
    |> fetch_user
    |> handle_token_response(conn)
  end

  defp handle_token_response({:ok, user}, conn) do
    conn
    |> put_private(:nusso_user, user)
  end

  defp handle_token_response({:error, reason}, conn) do
    with errors <- [error(reason.exception, reason.message)] do
      conn |> set_errors!(errors)
    end
  end

  defp fetch_user(token) do
    token
    |> NuSSO.API.redeem_token()
  end
end
