defmodule Ueberauth.Strategy.NuSSO.API do
  @moduledoc """
  NuSSO server API implementation.
  """

  @directory_failure ~s[{"fault":{"faultstring":"Execution of ServiceCallout Call-Directory-Search failed. Reason: ResponseCode 404 is treated as error","detail":{"errorcode":"steps.servicecallout.ExecutionFailed"}}}]
  @netid_email_domain "e.northwestern.edu"

  @doc "Returns the URL to the NuSSO server's login page"
  def login_url(callback) do
    with {:ok, response} <- get("get-ldap-redirect-url", goto: callback) do
      response |> Map.get(:redirecturl)
    end
  end

  @doc "Redeem an NuSSO SSO Token for the user attributes"
  def redeem_token(token) do
    case get("validateWebSSOToken", webssotoken: token) do
      {:ok, %{netid: netid}} ->
        if settings(:include_attributes, false),
          do: get_directory_attributes(token, %{uid: netid}),
          else: {:ok, %{uid: netid}}

      other ->
        other
    end
  end

  @doc "Retrieve the configured SSO cookie header name"
  def sso_cookie, do: settings(:sso_cookie, "nusso")

  def force_https(url) do
    with port <- settings(:ssl_port, 443) do
      case url |> URI.parse() do
        %URI{scheme: "https"} = uri -> uri
        uri -> %{uri | scheme: "https", port: port}
      end
      |> URI.to_string()
    end
  end

  defp consumer_key, do: settings(:consumer_key)

  defp get_directory_attributes(token, extra) do
    response =
      case get("validate-with-directory-search-response", webssotoken: token) do
        {:ok, response} -> response
        _ -> %{results: []}
      end

    {:ok, response |> handle_directory_attribute_response(extra)}
  end

  defp handle_directory_attribute_response(%{results: []}, extra) do
    extra[:uid] |> netid_user()
  end

  defp handle_directory_attribute_response(response, extra) do
    response
    |> Map.get(:results)
    |> List.first()
    |> Enum.map(fn
      {_, []} -> nil
      {_, ""} -> nil
      {key, value} when is_list(value) -> {to_atom(key), value |> List.first()}
      {key, value} -> {to_atom(key), value}
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.into(%{})
    |> Map.merge(extra)
  end

  defp to_atom(key) when is_atom(key), do: key
  defp to_atom(key) when is_binary(key), do: String.to_atom(key)
  defp to_atom(key), do: String.to_atom(to_string(key))

  defp settings(key, default \\ nil) do
    Application.get_env(:ueberauth, Ueberauth.Strategy.NuSSO, [])
    |> Keyword.get(key, default)
  end

  defp get(path, headers) do
    headers =
      headers
      |> Keyword.put(:apikey, consumer_key())
      |> Enum.map(fn {key, value} ->
        {to_string(key), to_string(value)}
      end)

    with client <- settings(:http_client, HTTPoison) do
      url_for(path)
      |> client.get(headers)
      |> handle_response()
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: ""}}) do
    {:ok, %{results: []}}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    Jason.decode(body, keys: :atoms)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 407}}) do
    {:error, %{exception: "Login Failed", message: "Missing, invalid, or expired SSO Token"}}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 500, body: @directory_failure}}) do
    {:ok, %{results: []}}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {:error, %{exception: "Unknown Response", status_code: status_code, message: body}}
  end

  defp url_for(path) do
    settings(:base_url)
    |> URI.merge(path)
    |> URI.to_string()
  end

  defp netid_user(net_id) do
    %{
      uid: net_id,
      displayName: net_id,
      givenName: net_id,
      sn: "(NetID)",
      mail: "#{net_id}@#{@netid_email_domain}"
    }
  end
end
