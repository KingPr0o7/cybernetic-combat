extends Control

@onready var host_username = $host_username_area/host_username
@onready var enemy_username = $enemy_username_area/enemy_username

func _ready() -> void:
	host_username.editable = false
	enemy_username.editable = false

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
				print(enemy_username.text)
				rpc_id(1, "set_enemy_username", username.text)

@rpc("any_peer")
func set_host_username(new_username: String) -> void:
	host_username.text = new_username

@rpc("any_peer")
func set_enemy_username(new_username: String) -> void:
	enemy_username.text = new_username

func _on_host_username_area_area_entered(area: Area2D) -> void:
	input_controller(host_username, area, area.get_parent().cursor_index, "enter")

func _on_host_username_area_area_exited(area: Area2D) -> void:
	input_controller(host_username, area, area.get_parent().cursor_index, "exit")

func _on_enemy_username_area_area_entered(area: Area2D) -> void:
	input_controller(enemy_username, area, area.get_parent().cursor_index, "enter")

func _on_enemy_username_area_area_exited(area: Area2D) -> void:
	input_controller(enemy_username, area, area.get_parent().cursor_index, "exit")
