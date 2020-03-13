defmodule ToDo.Echo do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(id))
  end

  def call(id, request) do
    GenServer.call(via_tuple(id), request)
  end

  def via_tuple(id) do
    {:via, Registry, {:myregistry, {__MODULE__, id}}}
  end

  def handle_call(request, _, state) do
    {:reply, request, state}
  end
end
