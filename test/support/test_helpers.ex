defmodule Ueberauth.NuSSO.TestHelpers do
  @moduledoc """
  Ueberauth.NuSSO test helpers, fixtures, etc
  """

  def dig(data, []), do: data
  def dig(data, [now | later]), do: data |> dig(now) |> dig(later)
  def dig(data, now) when is_number(now), do: data |> Enum.at(now)
  def dig(data, now) when is_binary(now) or is_atom(now), do: data |> Map.get(now)
end
