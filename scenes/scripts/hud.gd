extends CanvasLayer

var king_health = 100
var talon_health = 100

@onready var player_health = $MarginContainer/status_bar/player_health
@onready var enemy_health = $MarginContainer/status_bar/enemy_health

@onready var player_dummy = $MarginContainer/status_bar/player_preview/player_dummy
@onready var enemy_dummy = $MarginContainer/status_bar/enemy_preview/enemy_dummy

var player_progress = preload("res://sprites/ui/player_progress_bar/player_progress.png")
var enemy_progress = preload("res://sprites/ui/enemy_progress_bar/enemy_progress.png")

var player_progress_extreme = preload("res://sprites/ui/player_progress_bar/player_progress_extreme.png")
var enemy_progress_extreme = preload("res://sprites/ui/enemy_progress_bar/enemy_progress_extreme.png")

# All the available colors imported within the SpineSprite Node. 
const COLORS = {
	amethystine = "amethystine",
	plumshade = "plumshade",
	cerulia = "cerulia",
	deepwave = "deepwave",
	scarflare = "scarflare",
	crimsonite = "crimsonite",
	greenvive = "greenvive",
	terrain = "terrain",
	sienna = "sienna",
	bronzearth = "bronzearth",
	graphite = "graphite",
	midnight = "midnight"
}

# All the available animations imported within the SpineSprite Node. 
const ANIMATIONS = {
	block = "block",
	charged_kick = "charged_kick",
	die_behind = "die_behind",
	die_front = "die_front",
	fall = "fall",
	fight_stance = "fight_stance",
	hurt = "hurt",
	idle = "idle",
	jab_double = "jab_double",
	jab_single = "jab_single",
	jab_thousands = "jab_thousands",
	jump = "jump",
	kick = "kick",
	land = "land",
	launch = "launch",
	run = "run",
	run_stop = "run_stop",
	walk = "walk"
}

func extreme_health_bar(toggled, health_bar, new_texture, id):
	# LEFT -> RIGHT: 0
	# RIGHT -> LEFT: 1
	# TOP -> BOTTOM: 2
	# BOTTOM -> TOP: 3
	# CLOCKWISE: 4
	# COUNTERCLOCKWISE: 5
	# BILINEAR LEFT & RIGHT: 6
	# BILINEAR TOP & BOTTOM: 7
	# CLOCKWISE AND COUNTERCLOCKWISE: 8

	if toggled == true:
		health_bar.texture_progress = new_texture
		health_bar.fill_mode = 7 # BILINEAR TOP & BOTTOM
		health_bar.min_value = 0.01
		health_bar.rounded = true
		health_bar.exp_edit = true
	else:
		health_bar.texture_progress = new_texture

		if id == 1:
			health_bar.fill_mode = 1
		else: 
			health_bar.fill_mode = 0

		health_bar.min_value = 1
		health_bar.rounded = false
		health_bar.exp_edit = false

	#print(health_bar.min_value, health_bar.rounded, health_bar.exp_edit, health_bar.fill_mode)

func update_health(id, wanted_health):
	var health_bar
	var progress
	var progress_extreme

	if id == 1:
		health_bar = player_health
		progress = player_progress
		progress_extreme = player_progress_extreme
	else:
		health_bar = enemy_health
		progress = enemy_progress
		progress_extreme = enemy_progress_extreme

	if wanted_health > 2:
		if health_bar.texture_progress == progress:
			var tween = get_tree().create_tween()
			tween.tween_property(health_bar, "value", wanted_health, 0.2).set_trans(Tween.TRANS_LINEAR)
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(health_bar, "value", 3, 0.2).set_trans(Tween.TRANS_LINEAR)
			extreme_health_bar(true, health_bar, progress_extreme, id)
			await get_tree().create_timer(0.2).timeout
			extreme_health_bar(false, health_bar, progress, id)

			tween.stop()
			var tween2 = get_tree().create_tween()

			tween2.tween_property(health_bar, "value", wanted_health, 0.2).set_trans(Tween.TRANS_LINEAR)

	else:
		var tween = get_tree().create_tween()
		tween.tween_property(health_bar, "value", 3, 0.4).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(0.4).timeout
		extreme_health_bar(true, health_bar, progress_extreme, id)
	
		tween.stop()

		tween.tween_property(health_bar, "value", 0, 0.2).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(0.2).timeout
		health_bar.min_value = 0
		health_bar.value = 0

func _ready():
	player_dummy.set_skin(COLORS.cerulia)
	player_dummy.play_animation(ANIMATIONS.idle, true, 0)

	enemy_dummy.set_skin(COLORS.crimsonite)
	enemy_dummy.play_animation(ANIMATIONS.idle, true, 0)

func _on_hurt_king_pressed() -> void:
	king_health -= 25
	update_health(1, king_health)

func _on_hurt_talon_pressed() -> void:
	talon_health -= 25
	update_health(2, talon_health)

func _on_reset_pressed() -> void:
	king_health = 100
	talon_health = 100

	player_health.value = 100
	enemy_health.value = 100

	update_health(1, king_health)
	update_health(2, talon_health)

func _on_heal_king_pressed() -> void:
	king_health += 25
	update_health(1, king_health)

func _on_heal_talon_pressed() -> void:
	talon_health += 25
	update_health(2, talon_health)
