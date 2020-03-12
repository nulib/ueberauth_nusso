defmodule Ueberauth.NuSSO.MockEndpoint do
  @moduledoc """
  This module provides the mock HTTP endpoint for testing
  """

  @behaviour HTTPoison.Base
  @base_url "https://test.example.edu/agentless-websso"
  @redirecturl "https://test-nusso.example.edu/nusso/XUI/?#login&realm=test&authIndexType=service&service=ldap-registry&goto=https://example.edu/"

  def get("#{@base_url}/get-ldap-redirect-url", headers) do
    send_headers(headers)
    http_response(%{redirecturl: @redirecturl})
  end

  def get("#{@base_url}/validateWebSSOToken", headers) do
    send_headers(headers)
    headers |> Enum.into(%{}) |> get_in(["webssotoken"]) |> validate_response()
  end

  def get("#{@base_url}/validate-with-directory-search-response", headers) do
    send_headers(headers)

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

  defp validate_response("test-sso-token"), do: http_response(%{netid: "abc123"})
  defp validate_response("bad-sso-token"), do: http_response(407, %{redirecturl: @redirecturl})
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
  def start, do: :noop
  def stream_next(_), do: :noop
end
