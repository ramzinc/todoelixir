defmodule ToDo.System do
  use Supervisor

  def start_link do
    Supervisor.start_link(
      __MODULE__,
      nil
    )
  end

  def init(_) do
    Supervisor.init([ToDo.Cache, ToDo.DataBase, ToDo.Web],
      strategy: :one_for_one
    )
  end
end
