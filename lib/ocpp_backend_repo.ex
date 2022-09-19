defmodule OcppBackendRepo do
  use Ecto.Repo, otp_app: :ocpp_backend,
    adapter: Ecto.Adapters.Postgres
  @moduledoc """
    Ecto Repo module
  """
end
