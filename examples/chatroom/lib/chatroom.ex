defmodule ChatRoom do
  use Application

  defmodule ChatMessage do
    @derive {Poison.Encoder, only: [:user, :msg, :timestamp]}
    defstruct [:action, :room, :user, :msg, :timestamp]
  end

  def start(_type, _args) do
    StateHolder.start_state_holder([{:websocket, "/", &websocket_callback/1}, {:port, 8080}])
  end

  def websocket_callback({:text, msg}) do
    handle_msg(Poison.decode!(msg, as: %ChatMessage{}))
  end

  def handle_msg(%ChatMessage{action: "connect", room: room, user: user, msg: _msg}) do
    case StateHolder.Room.exists?(room) do
      true -> 
        StateHolder.Room.add_member(room, user, self())
        room_info = StateHolder.Room.get_room_info(room)
        messages = format_messages(room_info)
        json = Poison.encode!(messages)
        {:reply, json}
      false ->
        StateHolder.Room.create_room(room, user, self())
        :no_reply
    end
  end
  def handle_msg(%ChatMessage{action: "say", room: room, user: user, msg: msg}) do
    now = :os.system_time
    #store chat history
    StateHolder.Room.update_room(room, now, {user, msg})

    #broadcast to all connected users
    broadcast_msg = Poison.encode!(%ChatMessage{user: user, msg: msg, timestamp: now})
    StateHolder.Room.broadcast_text(room, broadcast_msg)
    :no_reply
  end

  defp format_messages(room_info) do
    for {key, value} <- Map.to_list(room_info), 
        {history_user, history_msg} = value, 
        do: %ChatMessage{user: history_user, msg: history_msg, timestamp: key}
  end


end
