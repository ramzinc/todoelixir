defmodule ToDo.DataBaseWorker do
  use GenServer

  def start(dbfolder) do
    GenServer.start(__MODULE__, dbfolder)
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  def save(worker_pid, key, value) do
    GenServer.cast(worker_pid, {:save, key, value})
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
