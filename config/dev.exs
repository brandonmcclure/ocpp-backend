use Mix.Config

config :ocpp_backend, OcppBackendRepo,
  adapter: Ecto.Adapters.Postgres,
  database: "ocpp_backend_dev",
  hostname: "10.0.1.2",
  username: "postgres",
  password: "postgres"

config :mix_docker, image: "addictivesoftware/ocpp_backend"
