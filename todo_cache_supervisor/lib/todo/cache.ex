defmodule ToDo.Cache do
  # use GenServer

  # @impl GenServer
  # def init(_) do
  #   IO.puts("I am starting the ToDo.Cache as a dynamic supervisor")
  #   # ToDo.DataBase.start_link(nil)
  #   {:ok, %{}}
  # end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def start_link() do
    # GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def start_child(todo_name) do
    DynamicSupervisor.start_child(__MODULE__, {ToDo.Server, todo_name})
  end

  def todo_server_process(todo_p_name) do
    # GenServer.call(__MODULE__, {:todoprocess, todo_p_name})
    lookup_server(todo_p_name) || new_todo(todo_p_name)
  end

  defp new_todo(todo_p_name) do
    case ToDo.Cache.start_child(todo_p_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp lookup_server(todo) do
    ToDo.Server.where_is(todo)
  end

  # @impl GenServer
  # def handle_call({:todoprocess, todoname}, _, todolistservers) do
  #   case(Map.fetch(todolistservers, todoname)) do
  #     {:ok, todopid} ->
  #       {:reply, todopid, todolistservers}

  #     :error ->
  #       {:ok, newtodopid} = ToDo.Server.start_link(todoname)

  #       {:reply, newtodopid,
  #        Map.put(
  #          todolistservers,
  #          todoname,
  #          newtodopid
  #        )}
  #   end
  # end
end
