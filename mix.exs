defmodule OcppBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ocpp_backend,
      version: "0.0.4",
      elixir: ">= 1.14.0",
      elixirc_paths: ["lib", "lib/model"],
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: { OcppBackend, [] },
      applications: [:cowboy, :ranch, :timex, :postgrex, :ecto],
      included_applications:  [:exjsx, :uuid, :earmark, :parse_trans]
    ]
  end

  defp deps do
    [ 
      { :cowboy,      "~> 2.9.0"},
      { :exjsx,       "~> 4.0.0" },
      { :uuid,        "~> 1.1" },
      { :timex,       "~> 3.0" },
      { :distillery,  "~> 2.1.1" },
      { :ecto,        "~> 3.8" },
      {:ecto_sql, "~> 3.0-rc.1"},
      { :postgrex,    "~> 0.16.4" },
      { :earmark,     "~> 1.4.27" }, 
      { :credo,       "~> 1.6.7", only: [:dev, :test], runtime: false},
      { :mock,        "~> 0.3.0", only: :test}
    ]
  end

  defp aliases do
    [
      check: ["clean", "compile", "test", "credo --strict"]
    ]
  end
end
