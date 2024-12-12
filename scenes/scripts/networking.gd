extends Control

var peer = ENetMultiplayerPeer.new()
@export var cursor_scene: PackedScene

var cursor

func create_server(port):
	"""
	Creates a server on a specified port, in which other players can join,
	with the host being the first player (ID 1). In which, an signal is 
	connected to listen for other joins, and triggers the connect_player
	function. 
	"""

	print("Creating server on port %d" % port)
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	# Called whenever a new player joins (automatically assigns an unique ID)
	multiplayer.peer_connected.connect(connect_player)
	connect_player(1) # Add the current player to their own view

func connect_player(id):
	"""
	With the server already made, this connects the player (via their ID),
	to the server, and instantiates a cursor for them to use. The cursor is
	in the root to keep the player within the viewport for the duration.
	"""

	print("Player connected with id %s" % id)
	cursor = cursor_scene.instantiate()
	cursor.name = str(id)
	var root = get_tree().root.get_children()
	root[0].add_child(cursor)
	
func join_server(port):
	"""
	Any new connection attempt, will be attempted on the specific port.
	If it's the host (ID 1), it'll attempt to join the port. However,
	the server isn't made, and it'll fall back to creating a server.
	When it's not the host, it directly connects (as the server exits).
	"""

	print("Attempting to join server on port %d" % port)
	peer.create_client("localhost", port)
	multiplayer.multiplayer_peer = peer

	for host_peer in peer.host.get_peers():
		host_peer.set_timeout(200, 500, 1000)

	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connection_failed():
	"""
	When the connection fails, it'll close the peer and create a server
	on the same port. This is to ensure that the player can still play
	the game, even if the host isn't available.
	"""
	
	print("Connection failed, creating server.")
	peer.close()
	create_server(135)

func _on_button_pressed() -> void:
	join_server(135)
