defmodule StateHolder.WebsocketHandler do

  def init(_, _req, _opts) do
  	{:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    {:ok, req, :undefined_state}
  end

  def websocket_handle(data, req, state) do
  	callback = state[:websocket_callback]
	Kernel.apply(callback, [data, req, state])
  end

  def websocket_info({:broadcast, broadcast_msg }, req, state) do
    {:reply, {:text, broadcast_msg}, req, state}
  end
  def websocket_info(_data, req, state) do
  	{:ok, req, state}
  end

  def websocket_terminate(_data, _req, _state) do
  	#TODO: unregister user
  	:ok
  end

  def broadcast(pids, msg) do
    Enum.each(pids, fn(pid) -> send(pid, msg) end)
  end

end
