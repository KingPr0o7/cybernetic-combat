extends Control

@onready var player_ready_status = $Host/host_ready_status
@onready var enemy_ready_status = $Enemy/enemy_ready_status

@onready var player_dummy = $Host/host_dummy
@onready var enemy_dummy = $Enemy/enemy_dummy

@onready var host_username = $Host/host_username_area/host_username
@onready var enemy_username = $Enemy/enemy_username_area/enemy_username

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

@onready var ready_button = $ready_up

func _ready() -> void:
	"""
	When loaded, we programmatically assign signals to the buttons for the color
	selection. As the Godot Engine doesn't support passing arguments to signals,
	we use a helper function to bind the color to the button.
	"""

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

	ready_button.pressed.connect(_on_ready_button_pressed.bind(ready_button))

func input_controller(username: LineEdit, area: Area2D, cursor_id: int, mode: String) -> void:
	"""
	Handles both the host and enemy mouse events of entering and exiting the
	username area. If the cursor is within the area, the username is editable.
	When the cursor exits the area, the username is no longer editable, and 
	therefore, the username is set to the cursor's text and fighter.
	"""

	username.grab_focus() # Make sure keyboard can be used
	var cursor = area.get_parent()
	if area.name == "cursor_area":
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
				cursor.set_username(username.text)
				rpc("set_host_username", username.text) # Reflect the change to the enemy
			if username.name == "enemy_username" and cursor_id != 1 and username.text != "":
				username.editable = false
				cursor.set_username(username.text)
				rpc("set_enemy_username", username.text) # Reflect the change to the host

func _on_color_call(button: TextureButton, color: String) -> void:
	"""
	To protect players from changing each other's colors,
	there are checks to find the cursor ID. When found,
	the player's color is set and reflected to the enemy.
	Making it impossible to change the enemy's color 
	(as they would just change their own).
	"""

	var button_area = button.get_node("%s_area" % color)
	var overlapping_areas = button_area.get_overlapping_areas()
	for area in overlapping_areas:
		var cursor_id = area.get_parent().cursor_index
		if cursor_id == 1:
			player_dummy.set_skin(color)
			rpc("set_host_color", color)
		else:
			enemy_dummy.set_skin(color)
			rpc("set_enemy_color", color)

func _on_ready_button_pressed(button: TextureButton) -> void:
	"""
	With the ready button pressed, the player's ready status
	is set to "Ready!" and the button is disabled.
	(Changes are reflected to the enemy).
	"""

	button.disabled = true
	var button_area = button.get_node("ready_area")
	var overlapping_areas = button_area.get_overlapping_areas()
	for area in overlapping_areas:
		var cursor_id = area.get_parent().cursor_index
		if cursor_id == 1:
			player_ready_status.text = "Ready!"
			ready_button.texture_normal = load("res://sprites/ui/buttons/readyed.png")
			rpc("set_host_ready_status")
		else:
			enemy_ready_status.text = "Ready!"
			ready_button.texture_normal = load("res://sprites/ui/buttons/readyed.png")
			rpc("set_enemy_ready_status")

#
# RPC Calls
#	These functions are programmatically called by the 
#	RPC system to update the host and enemy's username
#	and color.
#

@rpc("any_peer")
func set_host_username(new_username: String) -> void:
	host_username.text = new_username

@rpc("any_peer")
func set_enemy_username(new_username: String) -> void:
	enemy_username.text = new_username

#
# Colors
#

@rpc("any_peer")
func set_host_color(new_color: String) -> void:
	player_dummy.set_skin(new_color)

@rpc("any_peer")
func set_enemy_color(new_color: String) -> void:
	enemy_dummy.set_skin(new_color)

#
# Ready Status
#

@rpc("any_peer")
func set_host_ready_status() -> void:
	player_ready_status.text = "Ready!"

@rpc("any_peer")
func set_enemy_ready_status() -> void:
	enemy_ready_status.text = "Ready!"

#
# Process
#
#

func _process(_delta: float) -> void:
	"""
	Waits for both players to be ready before changing the scene.
	So that they have time to change their color and or username
	before the game starts.
	"""

	print(player_ready_status.text, enemy_ready_status.text)
	if player_ready_status.text == "Ready!" and enemy_ready_status.text == "Ready!":
		get_tree().change_scene("res://scenes/test_scene.tscn")

#
# Signals
#	Signals linked by the Godot Engine to the handle
#	the mouse events of entering and exiting the username
#	area (as no custom arguments are needed).
#

func _on_host_username_area_area_entered(area: Area2D) -> void:
	input_controller(host_username, area, area.get_parent().cursor_index, "enter")

func _on_host_username_area_area_exited(area: Area2D) -> void:
	input_controller(host_username, area, area.get_parent().cursor_index, "exit")

func _on_enemy_username_area_area_entered(area: Area2D) -> void:
	input_controller(enemy_username, area, area.get_parent().cursor_index, "enter")

func _on_enemy_username_area_area_exited(area: Area2D) -> void:
	input_controller(enemy_username, area, area.get_parent().cursor_index, "exit")
