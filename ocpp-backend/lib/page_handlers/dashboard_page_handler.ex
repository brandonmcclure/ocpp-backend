
defmodule PageHandlers.Dashboard do

  @moduledoc """
    Render the dashboard (landing page)
  """

  def init(req, state) do
    handle(req, state)
  end

  def handle(request, state) do
    req = :cowboy_req.reply(
      200,
      %{"content-type" => "text/html"},
      build_body(request),
      request
    )

    {:ok, req, state}
  end

  def terminate(_reason, _request, _state) do
    :ok
  end

  defp online_chargers do
    OnlineChargers.count
  end

  defp chargers do
    {:ok, chargers} = Chargepoints.subscribers
    chargers
  end

  defp tokens do
    {:ok, tokens} = Chargetokens.all
    tokens
  end

  defp sessions do
    {:ok, sessions} = Chargesessions.all(10, 0)
    sessions
  end

  def build_body(_request) do
    PageUtils.renderPage("dashboard.html", "Dashboard", [
        onlineChargers: online_chargers(),
        chargers: chargers(),
        tokens: tokens(),
        sessions: sessions()
      ])
  end
end
