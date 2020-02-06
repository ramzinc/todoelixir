defmodule ToDo.Server do
  use GenServer

  def start do
    GenServer.start(ToDo.Server, nil)
  end

  @impl GenServer
  def init(_) do
    {:ok, ToDo.List.new()}
  end

  def get(server_id, date) do
    GenServer.call(server_id, {:entries, date})
  end

  def add_entry(server_id, entry) do
    GenServer.cast(server_id, {:add_entry, entry})
  end

  @impl GenServer
  def handle_call({:add_entry, new_entry}, _, current_state) do
    {:noreply, ToDo.List.add_entry(current_state, new_entry)}
  end

  @impl GenServer
  def handle_call({:delete_entry, entry}, _, current_state) do
    {:reply, ToDo.List.delete_entry(current_state, entry),
     ToDo.List.delete_entry(current_state, entry)}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, current_state) do
    {:noreply, ToDo.List.add_entry(current_state, new_entry)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, current_state) do
    {:reply, ToDo.List.entries(current_state, date), current_state}
  end
end
