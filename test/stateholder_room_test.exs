defmodule StateHolder.RoomTests do
	use ExUnit.Case
  	doctest StateHolder.Room

 	setup do
 	end

 	test "create a room", context do
 		StateHolder.Room.create_room("room_name", "creator_name", self())
 		
 	end

end