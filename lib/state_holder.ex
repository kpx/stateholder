defmodule StateHolder do
  use Application

  def start(_type, _args) do
    StateHolder.Supervisor.start_link()
  end

  def start_state_holder(websocket_path, websocket_handler) do
    dispatch = :cowboy_router.compile([
                {:_, [{websocket_path, websocket_handler, []}]}
               ])
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [port: 8080],
                                  [env: [dispatch: dispatch]])
    
    #StateHolder.Supervisor.start_link()
  end
end
