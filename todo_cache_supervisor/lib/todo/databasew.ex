defmodule ToDo.DataBase do
  @folder "./persistance/"
  @poolsize 3

  def start_link() do
    IO.puts("Iam Starting  the ToDo.DataBase")
    File.mkdir_p(@folder)
    children = Enum.map(1..@poolsize, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def get(key) do
    choose_worker(key)
    |> ToDo.DataBaseWorker.get(key)
  end

  def save(key, value) do
    choose_worker(key)
    |> ToDo.DataBaseWorker.save(key, value)
  end

  # @impl GenServer
  # def init(_) do

  #   #IO.inspect(workers)

  #   {:ok, state}
  # end

  def worker_spec(worker_id) do
    current_spec = {ToDo.DataBaseWorker, {@folder, worker_id}}
    Supervisor.child_spec(current_spec, id: worker_id)
  end

  def choose_worker(key) do
    worker_key = :erlang.phash2(key, 3) + 1
  end

  # @impl GenServer
  # def handle_call({:get, key, worker_key}, _, state) do
  #   data = ToDo.DataBaseWorker.get(Map.get(state.workers, worker_key), key)
  #   {:reply, data, state}
  # end

  #   @impl GenServer
  #   def handle_cast({:save, key, value, worker_key}, state) do
  #     # encoded_value = :erlang.term_to_binary(value)
  #     # File.write(@folder <> key, encoded_value)
  #     # {:noreply, state}
  #     IO.puts("Ive reached here in the EXECUTION")
  #     IO.inspect(Map.get(state.workers, worker_key))
  #     ToDo.DataBaseWorker.save(Map.get(state.workers, worker_key), key, value)
  #     {:noreply, state}
  #   end
  #
end
