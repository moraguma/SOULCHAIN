extends Node


# Leaves a little window in which the player can jump after leaving the ground
func _coyote_time(entity):
	entity.coyote_timed = true
	yield(get_tree().create_timer(entity.COYOTE_TIME), "timeout")
	entity.can_jump = false


# Remembers a jump for a little window so the player can jump while not touching
# the ground
func _log_jump(entity):
	entity.jump_logged = true
	yield(get_tree().create_timer(entity.JUMP_LOG_TIME), "timeout")
	entity.jump_logged = false


# Given a kinematic body and the direction it wants to move in, moves it.
# 
# - Jumps are higher if the jump button is held
# - Coyote time is applied
# - Jumps are logged
func movement_process_default(entity, dir):
	var on_floor = entity.is_on_floor()
	var on_ceiling = entity.is_on_ceiling()
	
	# Horizontal Velocity
	var acceleration
	if dir.dot(entity.velocity) > 0:
		acceleration = entity.ACCELERATION
	else:
		acceleration = entity.DECELERATION
	
	var h_vel = Vector2(entity.velocity[0], 0).linear_interpolate(dir * entity.MAX_HORIZONTAL_SPEED, acceleration)
	
	# Vertical Velocity
	var v_vel = Vector2(0, entity.velocity[1])
	
	if on_ceiling:
		v_vel = Vector2(0, 0)
	
	if on_floor:
		v_vel = Vector2(0, 0)
		entity.coyote_timed = false
		entity.can_jump = true
	else:
		if not entity.coyote_timed:
			_coyote_time(entity)
	
	if entity.jump_logged and entity.can_jump:
		v_vel += Vector2(0, -entity.JUMP_SPEED)
		entity.can_jump = false
	
	if Input.is_action_just_pressed("jump"):
		if entity.can_jump:
			v_vel += Vector2(0, -entity.JUMP_SPEED)
			entity.can_jump = false
		else:
			_log_jump(entity)
	
	var gravity
	
	if v_vel[1] < 0 and Input.is_action_pressed("jump"):
		gravity = entity.HIGH_JUMP_GRAVITY
	else:
		gravity = entity.NORMAL_GRAVITY
	
	v_vel = v_vel.linear_interpolate(Vector2(0, 1) * entity.MAX_FALLING_SPEED, gravity)
	
	# Movement
	entity.velocity = Vector2(h_vel[0], v_vel[1])
	
	var snap = entity.SNAP if on_floor else Vector2(0, 0)
	
	entity.velocity = entity.move_and_slide_with_snap(entity.velocity, snap,  Vector2(0, -1))
