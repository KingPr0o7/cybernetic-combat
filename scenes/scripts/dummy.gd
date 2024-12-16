@tool
extends SpineSprite

@export var current_animation = "" # Send to Synchronizer 

@export_enum("Block", "Charged Kick", "Die Behind", "Die Front", "Fall", "Fight Stance", "Hurt", "Idle", "Jab Double", "Jab Single", "Jab Thousands", "Jump", "Kick", "Land", "Launch", "Run", "Run Stop", "Walk") var load_animation
@export var direction = 1
@export_enum("Amethystine", "Plumshade", "Cerulia", "Deepwave", "Scarflare", "Crimsonite", "Greenvive", "Terrain", "Sienna", "Bronzearth", "Graphite", "Midnight") var color

const COLORS = ["Amethystine", "Plumshade", "Cerulia", "Deepwave", "Scarflare", "Crimsonite", "Greenvive", "Terrain", "Sienna", "Bronzearth", "Graphite", "Midnight"]
const ANIMATIONS = ["Block", "Charged Kick", "Die Behind", "Die Front", "Fall", "Fight Stance", "Hurt", "Idle", "Jab Double", "Jab Single", "Jab Thousands", "Jump", "Kick", "Land", "Launch", "Run", "Run Stop", "Walk"]

var is_initialized = false

func play_animation(animation_name: String, loop: bool, track: int, reverse: bool = false, additive: bool = false, delay: float = 0.00):
	"""
	Plays or adds to the current animation state of the SpineSprite with a
	specified track number and looping state. If the animation adds to
	the current set animation, it requires a delay duration. Animations
	can also be played in reverse, if needed.
	"""
	
	var track_entry
	
	# Only play the animation if it's not already playing
	if current_animation != animation_name:
		current_animation = animation_name
		if additive == false:
			track_entry = self.get_animation_state().set_animation(animation_name, loop, track)
		else:
			track_entry = self.get_animation_state().add_animation(animation_name, delay, loop, track)
	
		if reverse == true:
			track_entry.set_reverse(true)
	# If animation is a duplicate, check if it wants to be played in reverse
	else:
		if reverse == true:
			if additive == false:
				track_entry = self.get_animation_state().set_animation(animation_name, loop, track)
			else:
				track_entry = self.get_animation_state().add_animation(animation_name, delay, loop, track)
			
			track_entry.set_reverse(true)
		
		if loop == true and self.get_animation_state().get_num_tracks() == 0:
			if additive == false:
				track_entry = self.get_animation_state().set_animation(animation_name, loop, track)
			else:
				track_entry = self.get_animation_state().add_animation(animation_name, delay, loop, track)		

func set_skin(new_color: String):
	"""
	Set's the stickman's skin color for the player. There is a set of 12
	available colors to choose from, defined at the const of COLORS.
	"""

	var skin = self.get_skeleton().get_data().find_skin(new_color)
	self.get_skeleton().set_skin(skin)

func _process(_delta):
	if is_initialized == false:
		self.get_skeleton().set_scale_x(direction)
		self.set_skin(COLORS[color].to_lower())
		is_initialized = true
	
	self.play_animation(ANIMATIONS[load_animation].to_lower().replace(" ", "_"), true, 0, false)