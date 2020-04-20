defmodule ToDo.DataBase do
  @folder "./persistance"

  def start_link() do
    IO.puts("Iam Starting  the ToDo.DataBase using start_link")

    # children = Enum.map(1..@poolsize, &worker_spec/1)
    # Supervisor.start_link(children, strategy: :one_for_one)
  end

  def child_spec(_) do
    [nod, _host] = "#{node()}" |> String.split("@")
    directory = @folder <> nod
    File.mkdir_p(directory)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: ToDo.DataBaseWorker,
        size: 3
      ],
      directory
    )
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      ToDo.DataBaseWorker.get(worker_pid, key)
    end)
  end

  def save(key, value) do
    {return_val, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :save_local,
        [key, value],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, fn x -> IO.puts("save failed on #{x}") end)
    :ok
  end

  def save_local(key, value) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      ToDo.DataBaseWorker.save(worker_pid, key, value)
    end)
  end

  # @impl GenServer
  # def init(_) do

  #   #IO.inspect(workers)

  #   {:ok, state}
  # end

  # def worker_spec(worker_id) do
  #   current_spec = {ToDo.DataBaseWorker, {@folder, worker_id}}
  #   Supervisor.child_spec(current_spec, id: worker_id)
  # end

  # def choose_worker(key) do
  #   worker_key = :erlang.phash2(key, 3) + 1
  # end

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
