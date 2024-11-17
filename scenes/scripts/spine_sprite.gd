extends SpineSprite

func await_walking():
	if Input.is_action_just_pressed("walk_left"):
		get_animation_state().set_animation("1_/walk normal", true, 0)
		get_skeleton().set_scale_x(-1)
		
	if Input.is_action_just_released("walk_left"):
		get_animation_state().set_animation("1_/idle", true, 0)
	
	if Input.is_action_just_pressed("walk_right"):
		get_animation_state().set_animation("1_/walk normal", true, 0)
		get_skeleton().set_scale_x(1)

	if Input.is_action_just_released("walk_right"):
		get_animation_state().set_animation("1_/idle", true, 0)

func await_running():
	if Input.is_action_just_pressed("run_left"):
		get_animation_state().set_animation("1_/run", true, 0)
		get_skeleton().set_scale_x(-1)
		
	if Input.is_action_just_released("run_left"):
		get_animation_state().set_animation("1_/idle", true, 0)
	
	if Input.is_action_just_pressed("run_right"):
		get_animation_state().set_animation("1_/run", true, 0)
		get_skeleton().set_scale_x(1)

	if Input.is_action_just_released("run_right"):
		get_animation_state().set_animation("1_/idle", true, 0)

func await_jump():
	if Input.is_action_just_pressed("jump"):
		get_animation_state().set_animation("1_/jump A", false, 0)
		get_animation_state().add_animation("1_/jump B", 1, false, 0)
		get_animation_state().add_animation("1_/jump C", 1, false, 0)
		get_animation_state().add_animation("1_/jump D", 1, false, 0)
		#get_animation_state().add_animation("1_/idle fight pose", 0.20, false, 0)
		get_animation_state().add_animation("1_/idle active", 1, true, 0)
		get_animation_state().add_animation("1_/idle", 1, true, 0)

func _process(_delta):
	await_walking()
	await_running()
	await_jump()
