defmodule Model.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
    Session Model
  """

  schema "session" do
    field :serial,          :string
    field :connector_id,    :string
    field :token,           :string
    field :start_time,      :naive_datetime
    field :stop_time,       :naive_datetime
    field :volume,          :integer
    field :duration,        :integer

    timestamps()
  end

  def changeset(session, params \\ %{}) do
    session
    	|> cast(params, [
              :serial,
              :connector_id,
              :token,
              :start_time,
              :stop_time,
              :volume,
              :duration
            ]
          )
  end
end
