defmodule ToDo.DataBase do
  use GenServer
  @folder "./persistance/"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def get(key) do
    worker_key = choose_worker(key)

    # ToDo.DataBaseWorker.get(worker_pid, key)
    GenServer.call(__MODULE__, {:get, key, worker_key})
  end

  def save(key, value) do
    worker_key = choose_worker(key)

    GenServer.cast(__MODULE__, {:save, key, value, worker_key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p(@folder)
    workers = start_workers()
    IO.inspect(workers)
    state = %{workers: workers}
    {:ok, state}
  end

  def start_workers() do
    workers =
      Enum.reduce(0..2, %{}, fn x, acc ->
        {:ok, pid} = ToDo.DataBaseWorker.start(@folder)
        acc = Map.put(acc, x, pid)
      end)
  end

  def choose_worker(key) do
    worker_key = :erlang.phash2(key, 3)
  end

  @impl GenServer
  def handle_call({:get, key, worker_key}, _, state) do
    data = ToDo.DataBaseWorker.get(Map.get(state.workers, worker_key), key)
    {:reply, data, state}
  end

  @impl GenServer
  def handle_cast({:save, key, value, worker_key}, state) do
    # encoded_value = :erlang.term_to_binary(value)
    # File.write(@folder <> key, encoded_value)
    # {:noreply, state}
    ToDo.DataBaseWorker.save(Map.get(state.workers, worker_key), key, value)
    {:noreply, state}
  end
end
