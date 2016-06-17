defmodule StateHolder do
  use Application

  def start(_type, _args) do
    StateHolder.Supervisor.start_link()
  end

  def start_state_holder(websocket_path, websocket_callback) do
    dispatch = :cowboy_router.compile([
                {:_, [{websocket_path, StateHolder.WebsocketHandler, [{:websocket_callback, websocket_callback}]}]}
               ])
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [port: 8080],
                                  [env: [dispatch: dispatch]])
  end
end
