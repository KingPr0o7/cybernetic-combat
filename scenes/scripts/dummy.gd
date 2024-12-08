@tool
extends SpineSprite

@export var current_animation = "" # Send to Synchronizer 
@export var direction = 1

func play_animation(animation_name: String, loop: bool, track: int, additive: bool = false, delay: float = 0.00):
	"""
	Plays or adds to the current animation state of the SpineSprite with a
	specified track number and looping state. If the animation adds to
	the current set animation, it requires a delay duration.
	"""
	
	if current_animation != animation_name: # Only play the animation if it's not already playing
		current_animation = animation_name
		if additive == false:
			self.get_animation_state().set_animation(animation_name, loop, track)
		else:
			assert(delay > 0.00, "Animation player cannot have a delay of: %sms. It has to be greater than 0.00ms." % delay)
			self.get_animation_state().add_animation(animation_name, delay, loop, track)

func set_skin(color: String):
	"""
	Set's the stickman's skin color for the player. There is a set of 12
	available colors to choose from, defined at the const of COLORS.
	"""

	var skin = self.get_skeleton().get_data().find_skin(color)
	self.get_skeleton().set_skin(skin)

func _process(_delta):
	if direction == -1:
		self.get_skeleton().set_scale_x(direction)