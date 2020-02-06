defmodule ToDo.Cache do
  use GenServer

  @impl GenServer
  def init(_) do
    ToDo.DataBase.start()
    {:ok, %{}}
  end

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def todo_server_process(cache_pid, todo_p_name) do
    GenServer.call(cache_pid, {:todoprocess, todo_p_name})
  end

  @impl GenServer
  def handle_call({:todoprocess, todoname}, _, todolistservers) do
    case(Map.fetch(todolistservers, todoname)) do
      {:ok, todopid} ->
        {:reply, todopid, todolistservers}

      :error ->
        {:ok, newtodopid} = ToDo.Server.start(todoname)

        {:reply, newtodopid,
         Map.put(
           todolistservers,
           todoname,
           newtodopid
         )}
    end
  end
end
