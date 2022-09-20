defmodule Chargesessions do
  use GenServer
  use Agent
  import Logger
  import Ecto.Query, only: [from: 2]
  alias Model.Session, as: Session

  @moduledoc """
  Provides access to charge sessions
  """

  def init(args) do
    {:ok, args}
  end

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    info "Started #{__MODULE__} #{inspect(pid)}"
    {:ok, pid}
  end

  # Client calls

  def all(limit, offset) do
    GenServer.call(Chargesessions, {:all, limit, offset})
  end

  def for_serial(serial, limit, offset) do
    GenServer.call(Chargesessions, {:serial, serial, limit, offset})
  end

  def start(connector_id, serial, id_tag, start_time) do
    GenServer.call(Chargesessions, {:start, connector_id, serial, id_tag, start_time})
  end

  def stop(transaction_id, volume, stop_time) do
    GenServer.call(Chargesessions, {:stop, transaction_id, volume, stop_time})
  end

  # callbacks

  def handle_call({:start, connector_id, serial, id_tag, start_time}, _from, state) do
    session = %Session{connector_id: connector_id |> Integer.to_string, serial: serial, token: id_tag, start_time: start_time}
    {:ok, inserted} = OcppBackendRepo.insert(session)
    {:reply, {:ok, inserted.id |> Integer.to_string}, state}
  end

  def handle_call({:stop, transaction_id, volume, end_time}, _from, state) do
    session = get_session(transaction_id)
    info inspect(session)
    duration = Timex.diff(end_time, session.start_time, :minutes)

    {:ok, updated} = update(transaction_id, %{stop_time: end_time, duration: duration, volume: volume})

    {:reply, {:ok, updated}, state}
  end

  def handle_call({:all, limit, offset}, _from, state) do
    sessions = OcppBackendRepo.all(
                from s in Session,
                order_by: [desc: s.start_time],
                limit: ^limit,
                offset: ^offset
               )
    {:reply, {:ok, sessions}, state}
  end

  def handle_call({:serial, serial, limit, offset}, _from, state) do
    sessions = OcppBackendRepo.all(
      from s in Session,
      where: s.serial == ^serial,
      order_by: [desc: s.start_time],
      limit: ^limit,
      offset: ^offset
    )
    {:reply, {:ok, sessions}, state}
  end

  def get_session(transaction_id) do
    sessions = OcppBackendRepo.all(
      from s in Session,
      where: s.id == ^transaction_id and is_nil(s.stop_time),
      limit: 1
    )
    sessions |> List.first
  end

  defp update(transaction_id, changes) do
    session = get_session(transaction_id)
    changeset = Session.changeset(session, changes)
    OcppBackendRepo.update(changeset)
  end
end
