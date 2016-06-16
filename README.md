# StateHolder

Cowboy + Websockets + Elixir Agents! Connect to a simple key-value storage through websockets. State holder keeps track of connected users and can broadcast messages to all connected to the same 'room'.

(Note that this project still is in an early stage and all functions are not in place yet, but feel free to try it out.)
## Installation

  1. Add stateholder to your list of dependencies in `mix.exs`:

        def deps do
          [{:stateholder, github: "kpx/stateholder"}]
        end

  2. Ensure stateholder is started before your application:

        def application do
          [applications: [:stateholder]]
        end

## Development

* Install [elixir](http://elixir-lang.org/install.html)

Install deps and run:

	$ mix deps.get
	$ iex -S mix

## Examples

### Super simple echo websocket server

  - Create an echo server that use StateHolder.WebsocketHandler
  - implement websocket_handle({:text, websocket_text}, req, state) :: {:reply, {:text, reply_message}, req, state}

  defmodule EchoServer.Websocket do
    def websocket_handle({:text, text}, req, state) do
      {:reply, {:text, text}, req, state}
    end
  end

  - Create your app and start StateHolder
  defmodule EchoServer do
    use Application
  
    def start(_type, _args) do
      StateHolder.start_state_holder("/", EchoServer.Websocket)
      # (Start some supervisor here if you want)
    end
  end

  - Use your favourite websocket client or whatever to connect
