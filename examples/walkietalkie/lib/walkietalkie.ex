defmodule Talkie do
  use Application

  def start(_type, _args) do
    StateHolder.start_state_holder([{:websocket, "/ws", &websocket_callback/1}, {:static_priv_dir, :walkietalkie, "/app/[...]", "static"}, {:port, 8080}])
  end

  def websocket_callback(msg) do
    handle_msg(msg)
  end

  def handle_msg({:text, "join"}) do
   	case StateHolder.Room.exists?(:channel1) do
      true -> 
        StateHolder.Room.add_member(:channel1, :john_doe, self())
      false ->
        StateHolder.Room.create_room(:channel1, :john_doe, self())
    end
    :no_reply
  end
  def handle_msg({:binary, msg}) do
   	StateHolder.Room.broadcast_binary(:channel1, msg)
   	:no_reply
  end

end