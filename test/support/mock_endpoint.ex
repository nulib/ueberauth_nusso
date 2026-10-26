defmodule Ueberauth.NuSSO.MockEndpoint do
  @moduledoc """
  Plug-based mock NuSSO endpoint used in tests.
  """

  @behaviour Plug

  import Plug.Conn

  @non_json_response """
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
  <html>
    <body>This is not a JSON response</body>
  </html>
  """

  @directory_failure ~s[{"fault":{"faultstring":"Execution of ServiceCallout Call-Directory-Search failed. Reason: ResponseCode 404 is treated as error","detail":{"errorcode":"steps.servicecallout.ExecutionFailed"}}}]
  @redirecturl "https://test-nusso.example.edu/nusso/XUI/?#login&realm=test&authIndexType=service&service=ldap-registry"

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(%Plug.Conn{method: "GET", request_path: request_path} = conn, _opts) do
    get(request_path, conn)
  end

  def call(conn, _opts), do: send_resp(conn, 405, "Method Not Allowed")

  def get("/agentless-websso/get-ldap-redirect-url", conn) do
    conn
    |> fetch_query_params()
    |> send_headers()
    |> respond_json(200, %{redirecturl: redirect_url(conn, false) })
  end

  def get("/agentless-websso/get-ldap-duo-redirect-url", conn) do
    conn
    |> fetch_query_params()
    |> send_headers()
    |> respond_json(200, %{redirecturl: redirect_url(conn, true) })
  end

  def get("/agentless-websso/validateWebSSOToken", conn) do
    conn
    |> fetch_query_params()
    |> send_headers()
    |> respond_from_tuple(validate_response(token(conn)))
  end

  def get("/directory-search/res/netid/bas/" <> _uid, conn) do
    conn
    |> fetch_query_params()
    |> send_headers()
    |> respond_from_tuple(directory_search_response(token(conn)))
  end

  def get(_, conn), do: send_resp(conn, 404, "Not Found")

  defp redirect_url(conn, duo) do
    goto = conn |> param_or_header("goto") || ""
    [@redirecturl, "goto=#{goto}", "duo=#{duo}"] |> Enum.join("&")
  end

  defp token(conn), do: param_or_header(conn, "webssotoken")

  defp param_or_header(conn, key) do
    downcased_key = String.downcase(key)

    case List.keyfind(conn.req_headers, downcased_key, 0) do
      {_, value} ->
        value

      _ ->
        conn.params |> Map.get(key)
    end
  end

  defp validate_response("test-sso-token"), do: {200, %{netid: "abc123"}}
  defp validate_response("bad-directory-sso-token"), do: {200, %{netid: "abc123"}}
  defp validate_response("bad-sso-token"), do: {407, %{redirecturl: @redirecturl}}
  defp validate_response("empty-directory-sso-token"), do: {200, %{netid: "abc123"}}
  defp validate_response("non-json-sso-token"), do: {200, %{netid: "abc123"}}
  defp validate_response("error-sso-token"), do: {500, ~s'"Server Error"'}
  defp validate_response(_), do: {404, "Not Found"}

  defp directory_search_response("test-sso-token") do
    {200,
     %{
       "results" => [
         %{
           "displayName" => ["Archie B. Charles"],
           "eduPersonNickname" => [],
           "givenName" => ["Archie B."],
           "mail" => "archie.charles@example.edu",
           "nuOtherTitle" => "",
           "nuStudentEmail" => "",
           "nuTelephoneNumber2" => "",
           "nuTelephoneNumber3" => "",
           "sn" => ["Charles"],
           "telephoneNumber" => "+1 847 555 5555",
           "title" => ["Test Dummy"]
         }
       ]
     }}
  end

  defp directory_search_response("bad-directory-sso-token"), do: {500, @directory_failure}
  defp directory_search_response("empty-directory-sso-token"), do: {200, ""}
  defp directory_search_response("non-json-sso-token"), do: {200, @non_json_response}
  defp directory_search_response(_), do: {404, "Not Found"}

  defp send_headers(conn) do
    conn.req_headers |> Enum.each(fn header -> send(self(), {:header, header}) end)
    conn
  end

  defp respond_from_tuple(conn, {status, body}) when is_map(body) do
    respond_json(conn, status, body)
  end

  defp respond_from_tuple(conn, {status, body}) do
    send_resp(conn, status, body)
  end

  defp respond_json(conn, status, map) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(map))
  end
end
