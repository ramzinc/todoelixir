defmodule ToDo.Cache do
  use GenServer

  @impl GenServer
  def init(_) do
    ToDo.DataBase.start()
    {:ok, %{}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def todo_server_process(todo_p_name) do
    GenServer.call(__MODULE__, {:todoprocess, todo_p_name})
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
