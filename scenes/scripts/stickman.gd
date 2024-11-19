extends CharacterBody2D

@onready var SPINE = $Sprite # SpineSprite Node

@onready var left_fist = $Sprite/left_fist/Area2D/left_fist_coll
@onready var right_fist = $Sprite/right_fist/Area2D/right_fist_coll

@onready var left_tibia = $Sprite/left_tibia/Area2D/left_tibia_coll
@onready var right_tibia = $Sprite/right_tibia/Area2D/right_tibia_coll

@export var gravity = 750
@export var walk_speed = 400
@export var run_speed = 800
@export var jump_speed = -400

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

enum STATES {IDLE, WALKING, RUNNING, JUMPING, PUNCHING, KICKING, RUN_STOP, HURT, DEAD} # State Initializer 
var state = STATES.IDLE
var current_animation = ""

#
# Animation Handlers
#   These functions, play_animation & set_skin change how the Stickman looks.
#   Both functions are called at least once to display a stickman onto the game scene, 
#   as it cannot be done through the editor. 
#

func play_animation(animation_name: String, loop: bool, track: int, additive: bool = false, delay: float = 0.00):
	"""
	Plays or adds to the current animation state of the SpineSprite with a
	specified track number and looping state. If the animation adds to
	the current set animation, it requires a delay duration.
	"""
	
	if current_animation != animation_name: # Only play the animation if it's not already playing
		current_animation = animation_name
		if additive == false:
			SPINE.get_animation_state().set_animation(animation_name, loop, track)
		else:
			assert(delay > 0.00, "Animation player cannot have a delay of: %sms. It has to be greater than 0.00ms." % delay)
			SPINE.get_animation_state().add_animation(animation_name, delay, loop, track)

func set_skin(color: String):
	"""
	Set's the stickman's skin color for the player. There is a set of 12
	available colors to choose from, defined at the const of COLORS.
	"""

	var skin = SPINE.get_skeleton().get_data().find_skin(color)
	SPINE.get_skeleton().set_skin(skin)

#
# Input to State Interpreter
#	These functions listen for keybind events to transition between 
#	different states, updating the state to be processed in the 
#	physics server or other game logic.
#

func input_listener(listener_state):
	"""
	Handles the input of bidirectional locomotion (A and D keys) and their state transitions. 
	Including their modifier, the SHIFT key. This function detects combinations such as 
	movement keys and other states (e.g., jumping) to determine the next state.
	"""

	# IDLE to WALKING
	if listener_state == STATES.IDLE:
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			state = STATES.WALKING

		if Input.is_action_pressed("punch"):
			state = STATES.PUNCHING

	# WALKING TO RUNNING OR IDLE		
	elif listener_state == STATES.WALKING:
		if Input.is_action_pressed("sprint"):
			state = STATES.RUNNING
		if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			state = STATES.IDLE	

	# RUNNING TO IDLE
	elif listener_state == STATES.RUNNING:
		if !Input.is_action_pressed("sprint"):
			state = STATES.IDLE
		if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			state = STATES.RUN_STOP

	#PUNCHING
	elif listener_state == STATES.PUNCHING:
		await get_tree().create_timer(0.30).timeout
		if !Input.is_action_pressed("punch"):
			play_animation(ANIMATIONS.idle, true, 0, true, 0.5)
			state = STATES.IDLE
#
# Physics Handlers
#	Controls and applies needed physics along with proceeding changes to the Stickman
#	character like the direction, animation, and velocity. 
#

func bidirectional_velocity(direction: int, speed: int):
	"""
	Takes in a direction to flip both the velocity and the facing direction
	of the Stickman character.
	"""
	if direction == 1:
		velocity.x += speed
	elif direction == -1:
		velocity.x -= speed

	SPINE.get_skeleton().set_scale_x(direction) # Flips the Stickman on the x-axis.

func _physics_process(_delta: float) -> void:
	"""
	Controls the continuous physics processes, and thus state of the Stickman
	within the level (velocity, direction, animation, and state).
	"""

	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")

	#velocity.y += gravity * delta

	velocity.x = 0

	match state:
		STATES.IDLE:
			input_listener(STATES.IDLE)
			play_animation(ANIMATIONS.idle, true, 0)
		STATES.WALKING:
			input_listener(STATES.WALKING)

			if right:
				bidirectional_velocity(1, walk_speed)
			if left:
				bidirectional_velocity(-1, walk_speed)

			play_animation(ANIMATIONS.walk, true, 0)
		STATES.RUNNING:
			input_listener(STATES.RUNNING)
		
			if right:
				bidirectional_velocity(1, run_speed)
			if left:
				bidirectional_velocity(-1, run_speed)

			play_animation(ANIMATIONS.run, true, 0)

		STATES.RUN_STOP:
			play_animation(ANIMATIONS.run_stop, false, 0)
			play_animation(ANIMATIONS.idle, true, 0, true, 0.8)
			state = STATES.IDLE

		STATES.PUNCHING:
			input_listener(STATES.PUNCHING)
			play_animation(ANIMATIONS.jab_single, false, 0)

	
	move_and_slide()

func _ready():
	set_skin(COLORS.midnight)
	left_fist.disabled = true
	right_fist.disabled = true

	left_tibia.disabled = true
	right_tibia.disabled = true
	#$Sprite/AnimationPlayer.play("jab_single")
