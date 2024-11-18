extends CharacterBody2D

@onready var SPRITE = $Sprite
@export var gravity = 750
@export var run_speed = 500
@export var jump_speed = -400

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

enum {IDLE, WALK, RUN, JUMP, PUNCH, KICK, HURT, DEAD} # State Initializer 
var state = IDLE

#
# Displayment Handlers
#   These functions, play_animation & set_skin change how the a Stickman looks.
#   Both functions are called at least one to display a stickman onto the game scnene, 
#   as it cannot be done through the editor. 
#

func play_animation(animation_name: String, loop: bool, track: int, additive: bool = false, delay: float = 0.00):
	"""
	Plays or adds to the current animation state of the SpineSprite with a
	specified track number and looping state. If the animation adds to
	the current set animation, it requires a delay duration.
	"""
	
	if additive == false:
		SPRITE.get_animation_state().set_animation(animation_name, loop, track)
	else:
		assert(delay > 0.00, "Animation player cannot have a delay of: %sms. It has to be greater than 0.00ms." % delay)
		SPRITE.get_animation_state().add_animation(animation_name, delay, loop, track)

func set_skin(color: String):
	"""
	Set's the stickman's skin color for the player. There is a set of 12
	available colors to choose from, defined at the const of COLORS.
	"""

	var skin = SPRITE.get_skeleton().get_data().find_skin(color)
	SPRITE.get_skeleton().set_skin(skin)

#
# State Machine
#   Describe.
#

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			play_animation(ANIMATIONS.idle, true, 0)
		WALK:
			play_animation(ANIMATIONS.walk, true, 0)
		RUN:
			play_animation(ANIMATIONS.run, true, 0)

#
# Input Handler 
#

func get_input():
	var walk_left = Input.is_action_pressed("walk_left")
	var walk_right = Input.is_action_pressed("walk_right")
	#var jump = Input.is_action_just_pressed("jump")

	velocity.x = 0

	if walk_right:
		velocity.x += run_speed
		SPRITE.get_skeleton().set_scale_x(1)
	elif walk_left:
		velocity.x -= run_speed
		SPRITE.get_skeleton().set_scale_x(-1)

	if state == IDLE and velocity.x != 0:
		change_state(WALK)

func _physics_process(delta: float) -> void:
	#velocity.y += gravity * delta
	get_input()
	move_and_slide()

func _ready():
	change_state(IDLE) # Starting State Machine
	set_skin(COLORS.midnight)
	play_animation("idle", true, 0)
