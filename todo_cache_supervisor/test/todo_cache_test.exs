defmodule ToDoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = ToDo.Cache.start()
    bob_pid = ToDo.Cache.todo_server_process(cache, "bob")

    assert bob_pid == ToDo.Cache.todo_server_process(cache, "bob")
    assert bob_pid != ToDo.Cache.todo_server_process(cache, "Alice")
  end

  test "to-do operations" do
    {:ok, cache} = ToDo.Cache.start()
    bob_pid = ToDo.Cache.todo_server_process(cache, "bob")
    ToDo.Server.add_entry(bob_pid, %{date: ~D[2020-01-12], title: "Elixir Wizards"})
    entries = ToDo.Server.get(bob_pid, ~D[2020-01-12])
    assert [%{date: ~D[2020-01-12], title: "Elixir Wizards"}] = entries
  end
end
