defmodule ToDo.List do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %ToDo.List{}, &add_entry(&2, &1))
  end

  def add_entry(todolist, entry) do
    # set the id of the entry with that stored in the structure's auto_id field
    entry = Map.put(entry, :id, todolist.auto_id)
    # add the entry to the entries collection
    new_entries = Map.put(todolist.entries, todolist.auto_id, entry)
    # Update the todolist struct instance with  the new_entries collection.
    %ToDo.List{todolist | entries: new_entries, auto_id: todolist.auto_id + 1}
  end

  def entries(todolist, date) do
    entries =
      todolist.entries
      |> Stream.filter(fn {_, entry} -> entry.date == date end)
      |> Enum.map(fn {_, entry} ->
        entry
      end)

    entries
  end

  def update_entry(todolist, id, update_fun) do
    case Map.fetch(todolist.entries, id) do
      :error ->
        "An error happend"

      {:ok, old_entry} ->
        # Make sure we are returning a map
        new_entry = %{} = update_fun.(old_entry)
        new_entries = Map.put(todolist.entries, new_entry.id, new_entry)
        %ToDo.List{todolist | entries: new_entries}
    end
  end

  def delete_entry(todolist, id) do
    entry = Map.delete(todolist.entries, id)
    %ToDo.List{todolist | entries: entry}
  end
end

defmodule ToDo.List.CsvImporter do
  def open_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> separate_dates
    |> ToDo.List.new()
  end

  def separate_dates(lines) do
    lines
    |> Stream.map(&separate_date_from_title/1)
  end

  def separate_date_from_title(dates_and_title_str) do
    dates_and_title_str
    |> IO.inspect()
    |> String.split(",")
    |> match_dates()
  end

  def match_dates([datestring, title]) do
    [year, month, date] = String.split(datestring, "/")

    {_, date_entry} =
      Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(date))

    create_entry({date_entry, title})
  end

  def create_entry({date_e, title}) do
    %{date: date_e, title: title}
  end
end

defimpl String.Chars, for: ToDo.List do
  def to_string(_) do
    "String representation of TodoList"
  end
end

defimpl Collectable, for: ToDo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    ToDo.List.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(todo_list, :halt), do: :ok
end

defmodule ServerProcess do
  def start(callbackmodule) do
    spawn(fn ->
      initial_state = callbackmodule.init()
      loop(callbackmodule, initial_state)
    end)
  end

  defp loop(callbackmodule, initial_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          callbackmodule.handle_call(
            request,
            initial_state
          )

        send(caller, {:response, response})

        loop(callbackmodule, new_state)

      {:cast, request} ->
        new_state = callbackmodule.handle_cast(request, initial_state)
        loop(callbackmodule, new_state)
    end
  end

  def cast(server_id, request) do
    send(server_id, {:cast, request})
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} ->
        response
    end
  end
end

# ToDo.List.CsvImporter.open_file("/home/zeus/experiments/elixir/elixir/todolist/todocsv.csv")
