import Config

config :ocpp_backend, OcppBackendRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "ocpp_backend_dev",
  hostname: "localhost",
  username: "postgres",
  password: "postgres"
