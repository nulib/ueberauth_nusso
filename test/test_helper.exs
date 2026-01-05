ExUnit.start(capture_log: true)
[:plug] |> Enum.each(&Application.ensure_started/1)
Req.default_options(plug: Ueberauth.NuSSO.MockEndpoint, retry: false)
