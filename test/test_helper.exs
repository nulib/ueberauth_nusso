ExUnit.start(capture_log: true)
Mox.defmock(HTTPMock, for: HTTPoison.Base)
[:mox, :plug] |> Enum.each(&Application.ensure_started/1)
