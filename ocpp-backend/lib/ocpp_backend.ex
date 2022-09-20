defmodule OcppBackend do
  use Application
  import Logger

  @moduledoc """
    Main entrypoint of the Application

    sets up the webserver and the routes
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = System.get_env("PORT")
            |> Utils.default("8383")
            |> String.to_integer

    info "Starting OCPP Backend application on #{port}"

    dispatch = :cowboy_router.compile routes()

    {:ok, _} = :cowboy.start_clear(:http,
                                   [{:port, port}],
                                   %{env: %{dispatch: dispatch}}
                                   )
    OcppBackend.Supervisor.start_link
  end

  defp routes do
    [{:_, static_routes() ++ websocket_routes() ++ page_routes() ++ api_routes()}]
  end

  defp static_routes do
    [{"/static/[...]", :cowboy_static, {:priv_dir,  :ocpp_backend, "static_files"}}]
  end

  defp websocket_routes do
    [{"/ocppws/:serial", WebsocketHandler, []}]
  end

  defp page_routes do
    [
      {"/", PageHandlers.Dashboard, []},
      {"/client", PageHandlers.WebsocketClient, []},
      {"/about", PageHandlers.About, []},
      {"/chargers", PageHandlers.Chargers, []},
      {"/chargers/:serial", PageHandlers.Charger, []},
      {"/dashboard", PageHandlers.Dashboard, []},
      {"/sessions", PageHandlers.Sessions, []},
      {"/tokens", PageHandlers.Tokens, []}]
  end

  defp api_routes do
    [{"/api/chargers/:serial/command", ApiHandlers.ChargerCommands, []}]
  end
end
