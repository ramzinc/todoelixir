defmodule ToDo.Application do
  use Application

  def start(_, _) do
    ToDo.System.start_link()
  end
end
