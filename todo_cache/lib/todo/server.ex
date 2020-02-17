defmodule ToDo.Server do
  use GenServer

  def start(todoname) do
    GenServer.start(ToDo.Server, todoname)
  end

  @impl GenServer
  def init(todoname) do
    {:ok, {todoname, ToDo.DataBase.get(todoname) || ToDo.List.new()}}
  end

  def get(server_id, date) do
    GenServer.call(server_id, {:entries, date})
  end

  def add_entry(server_id, entry) do
    GenServer.cast(server_id, {:add_entry, entry})
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {todo_listname, state}) do
    new_list = ToDo.List.add_entry(state, new_entry)
    ToDo.DataBase.save(todo_listname, new_list)

    {:noreply, {todo_listname, new_list}}
  end

  # @impl GenServer
  # def handle_call({:add_entry, new_entry}, _, {todo_list_name, current_state}) do
  #   {:noreply, ToDo.List.add_entry(current_state, new_entry)}
  # end

  @impl GenServer
  def handle_call({:entries, date}, _, {todo_listname, current_state}) do
    {:reply, ToDo.List.entries(current_state, date), current_state}
  end

  @impl GenServer
  def handle_call({:delete_entry, entry}, _, {todo_listname, current_state}) do
    {:reply, ToDo.List.delete_entry(current_state, entry),
     ToDo.List.delete_entry(current_state, entry)}

    {:reply, current_state, current_state}
  end
end
