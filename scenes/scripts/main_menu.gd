extends Control

@export var main_scene : PackedScene
@export var background_speed = 2000
@export var menu_speed = 2200

@export var background_index = 0
@export var moving_enabled = false

func _on_start_pressed() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(main_scene)

func _on_settings_pressed() -> void:
	moving_enabled = true
	background_index += 1

func _process(delta: float) -> void:
	"""
	Since the viewport is locked in place via the width and height
	(specified in the project settings), the background and menu
	scroll instead; the cursors are stationary (without intervention). 
	"""
	
	if moving_enabled == true:
		$background.scroll_offset.x -= background_speed * delta
		$all_menus.position.x -= menu_speed * delta

		if $all_menus.position.x <= -1920 * background_index:
			moving_enabled = false

func _on_button_2_pressed() -> void:
	moving_enabled = true
	background_index += 1