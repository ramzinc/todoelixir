defmodule ToDo.SimpleRegistry do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    tab = :ets.new(__MODULE__, [:named_table, :set, :public])
    IO.inspect(tab)
    {:ok, tab}
  end

  def register(name) do
    GenServer.call(__MODULE__, {:register, name, self()})
  end

  def check_name(name) do
    reply =
      case :ets.lookup(__MODULE__, name) do
        [{^name, value}] -> value
        [] -> nil
      end

    reply
  end

  def handle_call({:register, pname, pidv}, _, state) do
    rep =
      case :ets.insert_new(__MODULE__, {pname, pidv}) do
        true -> :ok
        false -> :error
      end

    {:reply, rep, state}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, state}
  end
end
