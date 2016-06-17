defmodule StateHolder do
  use Application

  def start(_type, _args) do
    StateHolder.Supervisor.start_link()
  end

  def start_state_holder(opts) do
    route_config = Enum.map(opts, 
      fn {:websocket, route, callback} ->
            {route, StateHolder.WebsocketHandler, [{:websocket_callback, callback}]}
         {:static, route, path} ->
            {route, :cowboy_static, {:file, path}}
         {:static_priv, app, route, path} ->
            {route, :cowboy_static, {:priv_file, app, path}}
         {:static_priv_dir, app, route, path} ->
            {route, :cowboy_static, {:priv_dir, app, path}}
      end)
    #[{:websocket, route, callback}, {:static, route, path}]
    #{"/", cowboy_static, {priv_file, my_app, "static/index.html"}}
    dispatch = :cowboy_router.compile([
                {:_, route_config}
               ])
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [port: 8080],
                                  [env: [dispatch: dispatch]])
  end
end
