defmodule StateHolder do
  use Application

  def start(_type, _args) do
    StateHolder.Supervisor.start_link()
  end

  def start_state_holder(opts) do
    route_config = List.foldl(opts, [], 
      fn {:websocket, route, callback}, acc ->
            [{route, StateHolder.WebsocketHandler, [{:websocket_callback, callback}]} | acc ]
         {:static, route, path}, acc ->
            [{route, :cowboy_static, {:file, path}} | acc ]
         {:static_priv, app, route, path}, acc ->
            [{route, :cowboy_static, {:priv_file, app, path}} | acc ]
         {:static_priv_dir, app, route, path}, acc ->
            [{route, :cowboy_static, {:priv_dir, app, path}} | acc ]
          _, acc ->
            # ignore othe config
            acc
      end)
    port = Keyword.get(opts, :port, 8080)
    dispatch = :cowboy_router.compile([{:_, route_config}])
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [port: port],
                                  [env: [dispatch: dispatch]])
  end
end
