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

  - Create an echo server and implement a websocket callback websocket_callback(atom(), String.t) :: {:reply, String.t} | :no_reply
  
	``` elixir	  
	defmodule EchoServer.Websocket do
	  def websocket_callback({:text, websocket_msg}) do
	    {:reply, websocket_msg}
	  end
	end
	```
  - Create your app and start StateHolder
	``` elixir  
	defmodule EchoServer do
	  use Application
	  
	  def start(_type, _args) do
	    StateHolder.start_state_holder([{:websocket, "/", &EchoServer.Websocket.websocket_callback/1}], 8080)
	    # (Start some supervisor here if you want)
	  end
	end
	```
  - Use your favourite websocket client or whatever to connect
