extends CanvasLayer

var king_health = 100
var talon_health = 100

@onready var player_health = $MarginContainer/status_bar/player_health
@onready var enemy_health = $MarginContainer/status_bar/enemy_health

@onready var player_dummy = $MarginContainer/status_bar/background_container/player_preview/player_dummy
@onready var enemy_dummy = $MarginContainer/status_bar/background_container/enemy_preview/enemy_dummy

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
	"""
	Due to the corner radius of my health bar, and quite odd shape, the health bar needs
	to be modified after a tween, at the end to maintain a outline-like path. To do this, 
	the health bar has its min_value, fill_mode, exponential_edit, and rounded properties 
	triggered to allow the health bar to go quicker at smaller values 
	(as the health bar is quite large).
	"""

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
			health_bar.fill_mode = 1 # RIGHT -> LEFT
		else: 
			health_bar.fill_mode = 0 # LEFT -> RIGHT

		health_bar.min_value = 1
		health_bar.rounded = false
		health_bar.exp_edit = false

func update_health(id, wanted_health):
	"""
	To make the health bar dynamic and smooth, we establish the current target,
	and then trigger things based of the wanted_health and the health bar's current
	value. When the health bar reaches the point where it looks odd 
	(going towards the center, instead to the middle of KO), we switch the health bar's
	properties to go up and down (bi-linearly). 
	"""

	var health_bar
	var progress
	var progress_extreme
	var dummy

	# Target Insurance
	if id == 1:
		health_bar = player_health
		progress = player_progress
		progress_extreme = player_progress_extreme
		dummy = player_dummy
	else:
		health_bar = enemy_health
		progress = enemy_progress
		progress_extreme = enemy_progress_extreme
		dummy = enemy_dummy

	# Dummy Animation Player
	if wanted_health < health_bar.value:
		dummy.play_animation(ANIMATIONS.hurt, false, 0)
		dummy.play_animation(ANIMATIONS.idle, true, 0, false, true, 0.45)
	elif health_bar.value <= health_bar.min_value:
		dummy.play_animation(ANIMATIONS.die_behind, false, 0, true, true, 0)
		dummy.play_animation(ANIMATIONS.idle, true, 0, false, true, 0.8)
	else:
		dummy.play_animation(ANIMATIONS.idle, true, 0, false, true, 0.45)
		# New healing animation 👀

	# Health Gained
	if wanted_health > 2:
		# If not heading towards weird spot
		if health_bar.texture_progress == progress:
			var tween = get_tree().create_tween()
			tween.tween_property(health_bar, "value", wanted_health, 0.2).set_trans(Tween.TRANS_LINEAR)
		else:
			var break_point = get_tree().create_tween()
			# Set it to the last value before (to not look ugly)
			break_point.tween_property(health_bar, "value", 3, 0.2).set_trans(Tween.TRANS_LINEAR)
			extreme_health_bar(true, health_bar, progress_extreme, id)

			break_point.stop()

			# Then switch to left and right and go as normal
			extreme_health_bar(false, health_bar, progress, id)

			var zero = get_tree().create_tween()
			zero.tween_property(health_bar, "value", wanted_health, 0.2).set_trans(Tween.TRANS_LINEAR)
	# Health Lost
	else:
		# Set it to the last value before (to not look ugly)
		var break_point = get_tree().create_tween()
		break_point.tween_property(health_bar, "value", 3, 0.4).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(0.4).timeout
		extreme_health_bar(true, health_bar, progress_extreme, id)
	
		break_point.stop()

		# Then switch to top and bottom and go to KO
		var zero = get_tree().create_tween()

		if wanted_health <= 0:
			zero.tween_property(health_bar, "value", health_bar.min_value, 0.2).set_trans(Tween.TRANS_LINEAR)
			# Emit Death Signal Here
			dummy.play_animation(ANIMATIONS.die_behind, false, 0)

func _ready():
	if player_dummy != null:
		player_dummy.set_skin(COLORS.cerulia)
		player_dummy.play_animation(ANIMATIONS.idle, true, 0)

	if enemy_dummy != null:
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
