extends Node2D

@onready var USERNAME = $cursor_area/username
@export var cursor_index = 0

var background_speed: float = 0

func _enter_tree():
	set_multiplayer_authority(name.to_int()) # Set authority
	cursor_index = name.to_int()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	USERNAME.text = str(cursor_index)

func _process(_delta: float) -> void:
	"""
	Upon any movement of the cursor, it's checked to see if it's
	within the viewport. This replicates the behavior of fullscreen
	mode (if it happens to be only in windowed mode).
	"""

	var viewport_size = get_viewport().size
	var mouse_position = get_viewport().get_mouse_position()

	if is_multiplayer_authority():
		if mouse_position.x >= 0 and mouse_position.x <= viewport_size.x and mouse_position.y >= 0 and mouse_position.y <= viewport_size.y:
			position = mouse_position
