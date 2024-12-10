extends Control

var peer = ENetMultiplayerPeer.new()
@export var cursor_scene: PackedScene

var cursor

func create_server(port):
	print("Creating server on port %d" % port)
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	# Called whenever a new player joins (automatically assigns an unique ID)
	multiplayer.peer_connected.connect(connect_player)
	connect_player(1) # Add the current player to their own view

func connect_player(id):
	print("Player connected with id %s" % id)
	cursor = cursor_scene.instantiate()
	cursor.name = str(id)
	call_deferred("add_child", cursor)

func join_server(port):
	print("Attempting to join server on port %d" % port)
	peer.create_client("localhost", port)
	multiplayer.multiplayer_peer = peer

	for host_peer in peer.host.get_peers():
		host_peer.set_timeout(200, 500, 1000)

	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connection_failed():
	print("Connection failed, creating server.")
	peer.close()
	create_server(135)

func _on_button_pressed() -> void:
	join_server(135)