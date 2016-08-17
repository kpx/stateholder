defmodule StateHolder.WebsocketHandler do
  @moduledoc """
  Module responsible for cowboy websocket connections, forwarding the text requests 
  and broadcast messages.
  """

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, opts) do
    {:ok, req, opts}
  end

  def websocket_handle({:text, text}, req, state) do
    callback = state[:websocket_callback]
    case Kernel.apply(callback, [text]) do
      :no_reply -> {:ok, req, state}
      {:reply, reply_msg} -> {:reply, {:text, reply_msg}, req, state}
    end
  end

  def websocket_info({:broadcast, broadcast_msg }, req, state) do
    #Send a message to the client when a message tagged with :broadcast is received 
    {:reply, {:text, broadcast_msg}, req, state}
  end
  def websocket_info(_data, req, state) do
    {:ok, req, state}
  end

  def websocket_terminate(_data, _req, _state) do
    #TODO: unregister user
    :ok
  end

  def broadcast(pids, msg), do: Enum.each(pids, fn(pid) -> send(pid, msg) end)

end
