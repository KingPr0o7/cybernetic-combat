extends Control

@onready var player_dummy = $host_dummy
@onready var enemy_dummy = $enemy_dummy

@onready var host_username = $host_username_area/host_username
@onready var enemy_username = $enemy_username_area/enemy_username

@onready var amethystine = $center_container/first_color_set/first_color_pair/amethystine
@onready var plumshade = $center_container/first_color_set/first_color_pair/plumshade
@onready var cerulia = $center_container/first_color_set/second_color_pair/cerulia
@onready var deepwave = $center_container/first_color_set/second_color_pair/deepwave
@onready var scarflare = $center_container/first_color_set/third_color_pair/scarflare
@onready var crimsonite = $center_container/first_color_set/third_color_pair/crimsonite

@onready var greenvive = $center_container/second_color_set/first_color_pair/greenvive
@onready var terrain = $center_container/second_color_set/first_color_pair/terrain
@onready var sienna = $center_container/second_color_set/second_color_pair/sienna
@onready var bronzearth = $center_container/second_color_set/second_color_pair/bronzearth
@onready var graphite = $center_container/second_color_set/third_color_pair/graphite
@onready var midnight = $center_container/second_color_set/third_color_pair/midnight

func _ready() -> void:
	host_username.editable = false
	enemy_username.editable = false

	amethystine.pressed.connect(_on_color_call.bind(amethystine, "amethystine"))
	plumshade.pressed.connect(_on_color_call.bind(plumshade, "plumshade"))
	cerulia.pressed.connect(_on_color_call.bind(cerulia, "cerulia"))
	deepwave.pressed.connect(_on_color_call.bind(deepwave, "deepwave"))
	scarflare.pressed.connect(_on_color_call.bind(scarflare, "scarflare"))
	crimsonite.pressed.connect(_on_color_call.bind(crimsonite, "crimsonite"))

	greenvive.pressed.connect(_on_color_call.bind(greenvive, "greenvive"))
	terrain.pressed.connect(_on_color_call.bind(terrain, "terrain"))
	sienna.pressed.connect(_on_color_call.bind(sienna, "sienna"))
	bronzearth.pressed.connect(_on_color_call.bind(bronzearth, "bronzearth"))
	graphite.pressed.connect(_on_color_call.bind(graphite, "graphite"))
	midnight.pressed.connect(_on_color_call.bind(midnight, "midnight"))

func input_controller(username: LineEdit, cursor: Node2D, cursor_id: int, mode: String) -> void:
	username.grab_focus()
	if cursor.name == "cursor_area":
		if mode == "enter":
			if username.name == "host_username":
				if cursor_id == 1:
					username.editable = true
				else:
					username.editable = false
			else:
				if cursor_id != 1:
					username.editable = true
				else:
					username.editable = false
		
		elif mode == "exit":
			if username.name == "host_username" and cursor_id == 1:
				username.editable = false
				rpc("set_host_username", username.text)
			if username.name == "enemy_username" and cursor_id != 1 and username.text != "":
				username.editable = false
				rpc_id(1, "set_enemy_username", username.text)

@rpc("any_peer")
func set_host_username(new_username: String) -> void:
	host_username.text = new_username

@rpc("any_peer")
func set_enemy_username(new_username: String) -> void:
	enemy_username.text = new_username

@rpc("any_peer")
func set_host_color(new_color: String) -> void:
	player_dummy.set_skin(new_color)

@rpc("any_peer")
func set_enemy_color(new_color: String) -> void:
	enemy_dummy.set_skin(new_color)

func _on_host_username_area_area_entered(area: Area2D) -> void:
	input_controller(host_username, area, area.get_parent().cursor_index, "enter")

func _on_host_username_area_area_exited(area: Area2D) -> void:
	input_controller(host_username, area, area.get_parent().cursor_index, "exit")

func _on_enemy_username_area_area_entered(area: Area2D) -> void:
	input_controller(enemy_username, area, area.get_parent().cursor_index, "enter")

func _on_enemy_username_area_area_exited(area: Area2D) -> void:
	input_controller(enemy_username, area, area.get_parent().cursor_index, "exit")

func _on_color_call(button: TextureButton, color: String) -> void:
	var area2d = button.get_node("%s_area" % color)
	var overlapping_areas = area2d.get_overlapping_areas()
	for area in overlapping_areas:
		var cursor_id = area.get_parent().cursor_index
		if cursor_id == 1:
			player_dummy.set_skin(color)
			rpc("set_host_color", color)
		else:
			enemy_dummy.set_skin(color)
			rpc_id(1, "set_enemy_color", color)
