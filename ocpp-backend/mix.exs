defmodule OcppBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ocpp_backend,
      version: "0.0.3",
      elixir: ">= 1.5.3",
      elixirc_paths: ["lib", "lib/model"],
      deps: deps(),
      aliases: aliases(),
      releases: [
        ocpp_backend: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  def application do
    [
      mod: { OcppBackend, [] },
      applications: [:cowboy, :ranch, :timex, :postgrex, :ecto],
      included_applications:  [:exjsx, :uuid, :earmark]
    ]
  end

  defp deps do
    [ 
      { :cowboy,      "~> 2.4.0"},
      { :exjsx,       "~> 4.0.0" },
      { :uuid,        "~> 1.1" },
      { :timex,       "~> 3.0" },
      { :distillery,  "~> 1.5.2" },
      { :postgrex,    "0.13.3" },
      { :ecto,        "~> 2.2.8" },
      { :earmark,     "~> 1.2.4" }, 
      { :credo,       "~> 0.9.1", only: [:dev, :test], runtime: false},
      { :mock,        "~> 0.3.0", only: :test},
      { :mix_docker, "~> 0.5.0"}
    ]
  end

  defp aliases do
    [
      check: ["clean", "compile", "test", "credo --strict"]
    ]
  end
end
