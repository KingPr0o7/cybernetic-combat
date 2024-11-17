extends Control

@export var main_scene : PackedScene

func _on_start_pressed() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(main_scene)
