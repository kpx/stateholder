# ChatRoom (Websocket)

Install deps and run (Chat room server autostarts):

	$ mix deps.get
	$ iex -S mix

Connect with your favourite websocket client.

javascript ex:

``` javascript
var socket = new WebSocket("ws://localhost:8080/");
 
socket.send('{"action": "connect", "user": "chatmaster_mike", "room": "awesome_chat"}');
socket.onmessage = function(event) { console.log(event.data); }

socket.send('{"action": "say", "user": "chatmaster_mike", "room": "awesome_chat", "msg": "Hello Chat, what\'s up?"}');

socket.send('{"action": "connect", "user": "anne_the_cool", "room": "awesome_chat"}');
socket.send('{"action": "say", "user": "anne_the_cool", "room": "awesome_chat", "msg": "Woho, I really like to chat"}');

```
