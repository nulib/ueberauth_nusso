defmodule Ueberauth.NuSSO.MockEndpoint do
  @moduledoc """
  This module provides the mock HTTP endpoint for testing
  """

  @behaviour HTTPoison.Base
  @base_url "https://test.example.edu"
  @non_json_response """
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
  <html>
    <body>This is not a JSON response</body>
  </html>
  """
  @redirecturl "https://test-nusso.example.edu/nusso/XUI/?#login&realm=test&authIndexType=service&service=ldap-registry"

  def get("#{@base_url}/agentless-websso/get-ldap-duo-redirect-url", headers) do
    with goto <- headers |> Enum.into(%{}) |> Map.get("goto"),
         url <- [@redirecturl, "goto=#{goto}"] |> Enum.join("&") do
      send_headers(headers)
      http_response(%{redirecturl: url})
    end
  end

  def get("#{@base_url}/agentless-websso/validateWebSSOToken", headers) do
    send_headers(headers)
    headers |> Enum.into(%{}) |> get_in(["webssotoken"]) |> validate_response()
  end

  def get("#{@base_url}/directory-search/res/netid/bas/" <> _uid, headers) do
    send_headers(headers)
    headers |> Enum.into(%{}) |> get_in(["webssotoken"]) |> directory_search_response()
  end

  defp directory_search_response("test-sso-token") do
    http_response(%{
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
    })
  end

  defp directory_search_response("bad-directory-sso-token") do
    {:ok,
     %HTTPoison.Response{
       status_code: 500,
       body:
         ~s[{"fault":{"faultstring":"Execution of ServiceCallout Call-Directory-Search failed. Reason: ResponseCode 404 is treated as error","detail":{"errorcode":"steps.servicecallout.ExecutionFailed"}}}]
     }}
  end

  defp directory_search_response("empty-directory-sso-token"),
    do: {:ok, %HTTPoison.Response{status_code: 200, body: ""}}

  defp directory_search_response("non-json-sso-token"),
    do: {:ok, %HTTPoison.Response{status_code: 200, body: @non_json_response}}

  defp validate_response("test-sso-token"), do: http_response(%{netid: "abc123"})
  defp validate_response("bad-directory-sso-token"), do: http_response(%{netid: "abc123"})
  defp validate_response("bad-sso-token"), do: http_response(407, %{redirecturl: @redirecturl})
  defp validate_response("empty-directory-sso-token"), do: http_response(%{netid: "abc123"})
  defp validate_response("non-json-sso-token"), do: http_response(%{netid: "abc123"})
  defp validate_response("error-sso-token"), do: http_response(500, "Server Error")

  defp send_headers(headers) do
    headers |> Enum.map(fn header -> send(self(), {:header, header}) end)
  end

  defp http_response(status \\ 200, map) do
    {:ok,
     %HTTPoison.Response{
       status_code: status,
       body: map |> Jason.encode!()
     }}
  end

  def delete!(_, _, _), do: :noop
  def delete!(_, _), do: :noop
  def delete!(_), do: :noop
  def delete(_, _, _), do: :noop
  def delete(_, _), do: :noop
  def delete(_), do: :noop
  def get!(_, _, _), do: :noop
  def get!(_, _), do: :noop
  def get!(_), do: :noop
  def get(_, _, _), do: :noop
  def get(_), do: :noop
  def head!(_, _, _), do: :noop
  def head!(_, _), do: :noop
  def head!(_), do: :noop
  def head(_, _, _), do: :noop
  def head(_, _), do: :noop
  def head(_), do: :noop
  def options!(_, _, _), do: :noop
  def options!(_, _), do: :noop
  def options!(_), do: :noop
  def options(_, _, _), do: :noop
  def options(_, _), do: :noop
  def options(_), do: :noop
  def patch!(_, _, _, _), do: :noop
  def patch!(_, _, _), do: :noop
  def patch!(_, _), do: :noop
  def patch(_, _, _, _), do: :noop
  def patch(_, _, _), do: :noop
  def patch(_, _), do: :noop
  def post!(_, _, _, _), do: :noop
  def post!(_, _, _), do: :noop
  def post!(_, _), do: :noop
  def post(_, _, _, _), do: :noop
  def post(_, _, _), do: :noop
  def post(_, _), do: :noop
  def process_headers(_), do: :noop
  def process_request_body(_), do: :noop
  def process_request_headers(_), do: :noop
  def process_request_options(_), do: :noop
  def process_request_params(_), do: :noop
  def process_request_url(_), do: :noop
  def process_response_body(_), do: :noop
  def process_response_chunk(_), do: :noop
  def process_response_headers(_), do: :noop
  def process_response_status_code(_), do: :noop
  def process_response(_), do: :noop
  def process_status_code(_), do: :noop
  def process_url(_), do: :noop
  def put!(_, _, _, _), do: :noop
  def put!(_, _, _), do: :noop
  def put!(_, _), do: :noop
  def put!(_), do: :noop
  def put(_, _, _, _), do: :noop
  def put(_, _, _), do: :noop
  def put(_, _), do: :noop
  def put(_), do: :noop
  def request!(_, _, _, _, _), do: :noop
  def request!(_, _, _, _), do: :noop
  def request!(_, _, _), do: :noop
  def request!(_, _), do: :noop
  def request(_, _, _, _, _), do: :noop
  def request(_, _, _, _), do: :noop
  def request(_, _, _), do: :noop
  def request(_, _), do: :noop
  def request(_), do: :noop
  def start, do: :noop
  def stream_next(_), do: :noop
end
