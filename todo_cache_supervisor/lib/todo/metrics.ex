defmodule ToDo.Metrics do
  use Task

  def start_link(_arg) do
    Task.start_link(&loop/0)
  end

  def loop() do
    Process.sleep(1000)

    IO.inspect(get_metrics())
    loop()
  end

  def get_metrics do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
