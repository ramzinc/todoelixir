defmodule ToDo.DataBaseWorker do
  use GenServer

  def start_link({dbfolder, worker_id}) do
    IO.puts("Start DBworker #{worker_id}")
    GenServer.start_link(__MODULE__, dbfolder, name: via_tuple(worker_id))
  end

  def get(worker_id, key) do
    IO.puts("I am getting the #{key} in DBWorker")
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def via_tuple(worker_id) do
    ToDo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  def save(worker_id, key, value) do
    GenServer.cast(via_tuple(worker_id), {:save, key, value})
  end

  @impl GenServer
  def init(dbfolder) do
    state = %{dbfolder: dbfolder, other_state: []}
    IO.inspect(state)
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data =
      case File.read(state.dbfolder <> key) do
        {:ok, contents} ->
          :erlang.binary_to_term(contents)

        _ ->
          nil
      end

    {:reply, data, state}
  end

  @impl GenServer
  def handle_cast({:save, key, value}, state) do
    encoded_value = :erlang.term_to_binary(value)
    IO.inspect(state.dbfolder)
    return = File.write(state.dbfolder <> key, encoded_value)
    {:noreply, state}
  end
end
