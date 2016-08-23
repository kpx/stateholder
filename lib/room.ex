defmodule StateHolder.Room do
  @moduledoc """
  Module handeling all functions for a room (key-value storage with connected users)
  """

  @agent_timeout 5000
  
  @doc """
  Creates a room with the given 'name' and adds the creating player
  to that room

  Returns :ok or :already_exists if there exists a room with that name
  """
  def create_room(room_name, creator, creator_pid) when is_binary(room_name) do
    atom_name = String.to_atom(room_name)
    create_room(atom_name, creator, creator_pid)
  end
  def create_room(room_name, creator, creator_pid) when is_atom(room_name) do  
    case exists?(room_name) do
      false -> 
        StateHolder.Supervisor.new_room(room_name)
        #Autojoin member that creates a room
        add_member(room_name, creator, creator_pid)
        :ok
      true ->
        :already_exists
    end
  end

  @doc """
  Adds a member and its websocket pid to the room
  """
  def add_member(room_name, member_name, member_pid) when is_binary(room_name) do
    atom_name = String.to_existing_atom(room_name)
    add_member(atom_name, member_name, member_pid)
  end
  def add_member(room_name, member_name, member_pid) when is_atom(room_name) do
    update_members = fn members -> MapSet.put(members, {member_name, member_pid}) end
    Agent.update(room_name, &Map.update(&1, :members, MapSet.new([{member_name, member_pid}]), update_members))
    :ok
  end

  @doc """
  Returns all members for a room
  """
  def get_members(room_name) when is_binary(room_name) do
    atom_name = String.to_existing_atom(room_name)
    get_members(atom_name)
  end
  def get_members(room_name) when is_atom(room_name) do
    room_info = get_room(room_name)
    members = Map.get(room_info, :members, MapSet.new())
    MapSet.to_list(members)
  end

  @doc """
  Updates data stored with key in room with name `room_name`  
  """
  def update_room(room_name, key, data) when is_binary(room_name) do
    atom_name = String.to_existing_atom(room_name)
    update_room(atom_name, key, data)
  end
  def update_room(room_name, key, data) when is_atom(room_name) do
    Agent.update(room_name, &Map.put(&1, key, data))
  end
 
  @doc """
  Returns all stored data in room except room member data
  """   
  def get_room_info(room_name) when is_binary(room_name) do
    atom_name = String.to_existing_atom(room_name)
    get_room_info(atom_name)
  end
  def get_room_info(room_name) when is_atom(room_name) do
    Map.drop(get_room(room_name), [:members])    
  end

  @doc """
  Broadcasts a text message `msg` to all members of the room 
  """
  def broadcast_text(room_name, msg) do
    broadcast(room_name, :text, msg)
  end

  @doc """
  Broadcasts a binary message `msg` to all members of the room 
  """
  def broadcast_binary(room_name, msg) do
    broadcast(room_name, :binary, msg)
  end

  @doc """
  Broadcasts a message `msg` to all members of the room 
  """
  def broadcast(room_name, type, msg) when is_binary(room_name) do
    atom_name = String.to_existing_atom(room_name)
    broadcast(atom_name, type, msg)
  end
  def broadcast(room_name, type, msg) when is_atom(room_name) do
    members = StateHolder.Room.get_members(room_name)
    #Tag the message as a broadcast (used by websocket handler)
    pids = Enum.map(members, fn({_, pid}) -> pid end)
    StateHolder.WebsocketHandler.broadcast(pids, type, msg)
  end

  @doc """
  Checks if a room with name `room_name` exists
  """
  def exists?(room_name) when is_binary(room_name) do
    exists?(String.to_atom(room_name))
  end
  def exists?(room_name) when is_atom(room_name) do
    Process.whereis(room_name) != nil
  end

  defp get_room(room_name) do
    Agent.get(room_name, fn x -> x end, @agent_timeout)
  end

end
