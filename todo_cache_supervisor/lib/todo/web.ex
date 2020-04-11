defmodule ToDo.Web do
  use Plug.Router
  @derive [Poison.Encoder]
  plug(:match)
  plug(:dispatch)

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    date = Date.from_iso8601!(Map.get(conn.params, "date"))
    title = Map.get(conn.params, "title")
    todo = Map.get(conn.params, "todo")

    respo =
      ToDo.Cache.todo_server_process(todo)
      |> ToDo.Server.add_entry(%{date: date, title: title})

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, "Added it to the list")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    todoname = Map.fetch!(conn.params, "todo")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    entries =
      todoname
      |> ToDo.Cache.todo_server_process()
      |> IO.inspect()
      |> ToDo.Server.get(date)

    formatted_entry =
      entries
      |> Enum.map(&Poison.encode!(%{date: &1.date, title: &1.title}))

    # {:ok, json_entries} =
    #   formatted_entry
    #   |> Poison.encode!()

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, formatted_entry)
  end

  def child_spec(_) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:todo, :http_port)],
      plug: __MODULE__
    )
  end
end
