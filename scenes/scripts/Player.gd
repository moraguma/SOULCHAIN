extends KinematicBody2D

export (PackedScene) var Hook
export (PackedScene) var JumpParticles
export (PackedScene) var BurstParticles
export (PackedScene) var Afterimage
export (PackedScene) var DeathParticles

# ------------------------------------------------
# MOVEMENT CONSTANTS

# HORIZONTAL -------------------------
# NORMAL ACCELERATION
const BURST_H_ACCELERATION = 0.01
const SWING_H_ACCELERATION = 0.007
const AIR_H_ACCELERATION = 0.04
const WALL_SLIDE_H_ACCELERATION = 0.2
const H_ACCELERATION = 0.1
const H_DECELERATION = 0.2

# TWEEN ACCELERATION
const WALL_JUMP_START_H_ACCELERATION = 0.01
const WALL_JUMP_END_H_ACCELERATION = 0.05
const WALL_JUMP_IMPULSE_START_H_ACCELERATION = 0.03
const WALL_JUMP_IMPULSE_END_H_ACCELERATION = 0.05
const BURST_START_H_ACCELERATION = 0
const BURST_END_H_ACCELERATION = 0.05
const IMPULSE_JUMP_START_H_ACCELERATION = 0
const IMPULSE_JUMP_END_H_ACCELERATION = 0.05

# HORIZONTAL MAX SPEED
const BURST_H_MAX_SPEED = 70
const H_MAX_SPEED = 85
const AIR_H_MAX_SPEED = 100
const WALL_SLIDE_H_MAX_SPEED = 90
const SWING_H_MAX_SPEED = 500

# TWEEN HORIZONTAL MAX SPEED
const WALL_JUMP_START_H_MAX_SPEED = 50
const WALL_JUMP_END_H_MAX_SPEED = 70
const WALL_JUMP_IMPULSE_START_H_MAX_SPEED = 60
const WALL_JUMP_IMPULSE_END_H_MAX_SPEED = 70
const BURST_START_H_MAX_SPEED = 30
const BURST_END_H_MAX_SPEED = 90
const IMPULSE_JUMP_START_H_MAX_SPEED = 120
const IMPULSE_JUMP_END_H_MAX_SPEED = 100

# JUMP HORIZONTAL SPEED
const WALL_JUMP_H_SPEED = 130
const WALL_JUMP_IMPULSE_H_SPEED = 160
const WALL_SPIN_JUMP_H_SPEED = 70
const WALL_SPIN_JUMP_IMPULSE_H_SPEED = 50
const IMPULSE_JUMP_H_SPEED = 400

# VERTICAL ---------------------
# GRAVITY
const GRAVITY = 0.09
const HIGH_JUMP_GRAVITY = 0.032
const WALL_SLIDE_GRAVITY = 0.1
const SWING_GRAVITY = 0.05
const MOVING_PLAT_SLIDE_GRAVITY = 0.1

# TWEEN GRAVITY
const WALL_JUMP_START_GRAVITY = 0
const WALL_JUMP_END_GRAVITY  = 0.09
const WALL_JUMP_IMPULSE_START_GRAVITY = 0
const WALL_JUMP_IMPULSE_END_GRAVITY = 0.09
const BURST_START_GRAVITY = 0
const BURST_END_GRAVITY = 0.05
const IMPULSE_JUMP_START_GRAVITY = 0.1
const IMPULSE_JUMP_END_GRAVITY = 0.09

# VERTICAL MAX SPEED
const V_MAX_SPEED = 190
const WALL_SLIDE_V_MAX_SPEED = 40
const SWING_V_MAX_SPEED = 300
const MOVING_PLAT_SLIDE_V_MAX_SPEED = 15

# TWEEN VERTICAL MAX SPEED
const WALL_JUMP_START_V_MAX_SPEED = 0
const WALL_JUMP_END_V_MAX_SPEED  = 170
const WALL_JUMP_IMPULSE_START_V_MAX_SPEED = 0
const WALL_JUMP_IMPULSE_END_V_MAX_SPEED = 170
const BURST_START_V_MAX_SPEED = 0
const BURST_END_V_MAX_SPEED = 170
const IMPULSE_JUMP_START_V_MAX_SPEED = 20
const IMPULSE_JUMP_END_V_MAX_SPEED = 190

# JUMP VERTICAL SPEED
const SPIN_JUMP_V_SPEED = 160
const HOOK_JUMP_V_SPEED = 100
const JUMP_V_SPEED = 150
const WALL_JUMP_V_SPEED = 100
const WALL_JUMP_IMPULSE_V_SPEED = 300
const WALL_SPIN_JUMP_V_SPEED = 100
const WALL_SPIN_JUMP_IMPULSE_V_SPEED = 200
const IMPULSE_JUMP_V_SPEED = 120

const MIN_IMPULSE_V_SPEED = 300
const MIN_IMPULSE_H_SPEED = 250

# TIMES --------------------
const WALL_JUMP_TWEEN_TIME = 0.15
const WALL_JUMP_IMPULSE_TWEEN_TIME = 0.15 
const BURST_TWEEN_TIME = 0.15
const IMPULSE_JUMP_TWEEN_TIME = 0.25

# OTHER --------------------
const BURST_SPEED = 350
const CHAIN_ELASTIC_CONSTANT = 150

const MAX_MOVING_PLAT_SPEED = 5
const MOVING_PLAT_VELOCITY_MODIFIER = 1.8
const SWING_SPEED_MULTIPLIER = 0.25
const SMALL_VERTICAL_WALL_JUMP_MULTIPLIER = 0.5


# ------------------------------------------------

# ------------------------------------------------
# VISUAL CONSTANTS

const CUTSCENE_EXTRA_FALLING_SPEED = 20
const CUTSCENE_GRAVITY = 500
const DEATH_DISTANCE = 16
const TOTAL_AFTERIMAGES = 3
const TURN_SPEED_MINIMUM = 2
const AIR_SPEED_INTERVAL = 40
const WALK_MIN_SPEED = 20
const DEATH_EXPLODE_TIME = 0.4
const DEATH_LINGER_TIME = 0.9
const FEET_VECTOR = Vector2(0, 8)
const CUTSCENE_END_WAIT_TIME = 0.1
# ------------------------------------------------

# ------------------------------------------------
# MOVEMENT VARIABLES

var dir = Vector2(0, 0)
var velocity = Vector2(0, 0)
var hook = null

var h_acceleration = 0
var h_max_speed = 0
var jump_h_speed = 0

var gravity = 0
var v_max_speed = 0
var jump_v_speed = 0

var cutscene_mode = false
var can_wall_jump = false
var on_wall = false
var on_floor = false
var is_swinging = false

var has_hook = true
var is_dead = false
var is_transitioning = false
var coyote_timed = false
var can_jump = true
var jump_logged = false
var wall_jumping = false
var bursting = false
var dialogue_target = null
# ------------------------------------------------

# ------------------------------------------------
# NODES

onready var parent = get_parent()
onready var main = parent.main
onready var raycast_controller = $RaycastController
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var camera = $Camera
onready var dialogue_sticker = $DialogueSticker

# TWEENS 
onready var h_acceleration_tween = $TweenController/HAccelerationTween
onready var h_speed_tween = $TweenController/HSpeedTween
onready var gravity_tween = $TweenController/GravityTween
onready var v_speed_tween = $TweenController/VSpeedTween
onready var cutscene_tween = $TweenController/CutsceneTween

# TIMERS 
onready var coyote_time_timer = $TimerController/CoyoteTimeTimer
onready var log_jump_timer = $TimerController/LogJumpTimer
onready var afterimage_timer = $TimerController/AfterimageTimer

# SOUNDS 
onready var jump_sound = $JumpSound
onready var burst_sound = $BurstSound
onready var land_sound = $LandSound
onready var walk_sound = $WalkSound
onready var death_sound = $DeathSound
# ------------------------------------------------

# Physics processing. Encompasses player input, movement and animation
func _physics_process(delta):
	if Input.is_action_just_pressed("menu"):
		parent.back_to_menu()
	
	if not is_transitioning:
		if not is_dead:
			if not cutscene_mode:
				if Input.is_action_just_pressed("restart"):
					death(Vector2(0, 0))
				
				_movement_process(delta)
				_animation_process()
				
				if not parent.is_inside(position):
					death(Vector2(0, -3))
			else:
				_cutscene_process()
	else:
		if is_on_floor():
			animation_player.try_play_animation("walk")
		else:
			animation_player.try_play_animation("air")


# Clamps vector into 8 directions. Returns normalized
func clamp_vector(v):
	if v != Vector2(0, 0):
		var angle = v.angle()
		
		if -7 * PI / 8 <= angle and angle < -5 * PI / 8:
			return Vector2(-1, -1)
		elif -5 * PI / 8 <= angle and angle < -3 * PI / 8:
			return Vector2(0, -1)
		elif -3 * PI / 8 <= angle and angle < -1 * PI / 8:
			return Vector2(1, -1)
		elif -1 * PI / 8 <= angle and angle < 1 * PI / 8:
			return Vector2(1, 0)
		elif 1 * PI / 8 <= angle and angle < 3 * PI / 8:
			return Vector2(1, 1)
		elif 3 * PI / 8 <= angle and angle < 5 * PI / 8:
			return Vector2(0, 1)
		elif 5 * PI / 8 <= angle and angle < 7 * PI / 8:
			return Vector2(-1, 1)
		else:
			return Vector2(-1, 0)
	
	return Vector2(0, 0)


# Returns the normalized vector that points to where the player intends to move
func get_dir():
	var d = Vector2(0, 0)
	
	d[0] = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	d[1] = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return clamp_vector(d)


# Leaves a little window in which the player can jump after leaving the ground
func start_coyote_time():
	coyote_timed = true
	coyote_time_timer.start()


# Called on coyote time timer timeout. Ends coyote time
func end_coyote_time():
	can_jump = false


# Remembers a jump for a little window so the player can jump while not touching
# the ground
func log_jump():
	jump_logged = true
	log_jump_timer.start()


# Called on log jump timer timeout. Unlogs a jump
func unlog_jump():
	jump_logged = false


func start_tweens():
	h_acceleration_tween.start()
	h_speed_tween.start()
	gravity_tween.start()
	v_speed_tween.start()


func add_jump_smoke():
	var jump_particles = JumpParticles.instance()
	jump_particles.position = position + FEET_VECTOR
	jump_particles.velocity = raycast_controller.get_moving_plat_velocity()
	parent.add_child(jump_particles)


func create_afterimage():
	for i in range(TOTAL_AFTERIMAGES):
		afterimage_timer.start()
		yield(afterimage_timer, "timeout")
		
		var afterimage = Afterimage.instance()
		
		afterimage.position = position
		afterimage.set_texture(sprite.get_texture())
		afterimage.vframes = sprite.vframes
		afterimage.hframes = sprite.hframes
		afterimage.frame = sprite.frame
		afterimage.flip_h = sprite.flip_h
		
		parent.add_child(afterimage)


func get_moving_platform_speed():
	return raycast_controller.get_moving_plat_velocity() * MOVING_PLAT_VELOCITY_MODIFIER


func _movement_process(delta):
	var wall_normal = raycast_controller.get_wall_normal()
	on_floor = raycast_controller.is_on_floor() and not velocity[1] < 0
	on_wall = is_on_wall() or wall_normal.dot(raycast_controller.get_moving_plat_velocity()) > 0
	var can_wall_jump = raycast_controller.is_on_wall()
	var hook_fixed = false
	var is_swinging = false
	var moving_plat_vel = raycast_controller.get_moving_plat_velocity()
	var is_sliding_on_moving_plat = wall_normal.dot(moving_plat_vel) > 0.5 and moving_plat_vel.distance_to(Vector2(0, 0)) > MAX_MOVING_PLAT_SPEED and not (velocity.dot(moving_plat_vel) > 0 and velocity.distance_to(Vector2(0, 0)) > moving_plat_vel.distance_to(Vector2(0, 0)))
	if not has_hook:
		hook_fixed = hook.is_fixed()
		is_swinging = hook.player_is_tensioned()
	
	if on_floor:
		get_tree().call_group("Tile", "rehook_tiles")
	
	if not can_jump and on_floor:
		can_jump = true
		
		land_sound.play()
		
		animation_player.try_play_animation("land")
		add_jump_smoke()
	
	dir = get_dir()
	
	# HORIZONTAL CONSTANTS UPDATE
	# Burst and wall jumping are the uninterruptable ones, so they get defined 
	# once they happen
	
	var aim_h_acceleration
	var aim_h_max_speed
	
	if on_floor:
		aim_h_max_speed = H_MAX_SPEED
		if dir.dot(velocity) > 0:
			aim_h_acceleration = H_ACCELERATION
		else:
			aim_h_acceleration = H_DECELERATION
	elif on_wall and velocity[1] > 0:
		aim_h_acceleration = WALL_SLIDE_H_ACCELERATION
		aim_h_max_speed = WALL_SLIDE_H_MAX_SPEED
	elif is_swinging:
		aim_h_acceleration = SWING_H_ACCELERATION
		aim_h_max_speed = SWING_H_MAX_SPEED
	else:
		aim_h_acceleration = AIR_H_ACCELERATION
		aim_h_max_speed = AIR_H_MAX_SPEED
	
	if not h_acceleration_tween.is_active():
		h_acceleration = aim_h_acceleration
	if not h_speed_tween.is_active():
		h_max_speed = aim_h_max_speed
	
	# VERTICAL CONSTANTS UPDATE
	
	var aim_gravity
	var aim_v_max_speed
	
	if is_sliding_on_moving_plat:
		aim_gravity = MOVING_PLAT_SLIDE_GRAVITY
		aim_v_max_speed = MOVING_PLAT_SLIDE_V_MAX_SPEED
	elif on_wall and velocity[1] > 0:
		aim_gravity = WALL_SLIDE_GRAVITY
		aim_v_max_speed = WALL_SLIDE_V_MAX_SPEED
	elif is_swinging:
		aim_gravity = SWING_GRAVITY
		aim_v_max_speed = SWING_V_MAX_SPEED
	else:
		aim_v_max_speed = V_MAX_SPEED
		if velocity[1] < 0 and Input.is_action_pressed("jump"):
			aim_gravity = HIGH_JUMP_GRAVITY
		else:
			aim_gravity = GRAVITY
	
	if not gravity_tween.is_active():
		gravity = aim_gravity
	if not v_speed_tween.is_active():
		v_max_speed = aim_v_max_speed
	
	# H_VEL AND V_VEL PROCESSING	
	var h_vel = Vector2(velocity[0], 0).linear_interpolate(h_max_speed * Vector2(dir[0], 0), h_acceleration)
	var v_vel = Vector2(0, velocity[1]).linear_interpolate(v_max_speed * Vector2(0, 1), gravity)
	
	# INPUTS
	if on_floor:
		coyote_timed = false
		can_jump = true
	else:
		if not coyote_timed:
			start_coyote_time()
	
	if Input.is_action_just_pressed("jump"):
		log_jump()
	
	if jump_logged:
		var add_h_vel = Vector2(0, 0)
		var add_v_vel = Vector2(0 ,0)
		
		if can_jump or can_wall_jump or hook_fixed:
			jump_logged = false
			jump_sound.play()
			
			var add_mov_plat_vel = get_moving_platform_speed()
			add_h_vel = Vector2(add_mov_plat_vel[0], 0)
			add_v_vel = Vector2(0, add_mov_plat_vel[1])
		
		if can_jump:
			can_jump = false
			add_jump_smoke()
			if abs(velocity[0]) > MIN_IMPULSE_H_SPEED:
				v_vel = IMPULSE_JUMP_V_SPEED * Vector2(0, -1)
				
				var facing_dir
				if sprite.flip_h:
					facing_dir = Vector2(-1, 0)
				else:
					facing_dir = Vector2(1, 0)
				
				h_vel = IMPULSE_JUMP_H_SPEED * facing_dir
				
				h_acceleration_tween.interpolate_property(self, "h_acceleration", IMPULSE_JUMP_START_H_ACCELERATION, IMPULSE_JUMP_END_H_ACCELERATION, IMPULSE_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				h_speed_tween.interpolate_property(self, "h_max_speed", IMPULSE_JUMP_START_H_MAX_SPEED, IMPULSE_JUMP_END_H_MAX_SPEED, IMPULSE_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				gravity_tween.interpolate_property(self, "gravity", IMPULSE_JUMP_START_GRAVITY, IMPULSE_JUMP_END_GRAVITY, IMPULSE_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				v_speed_tween.interpolate_property(self, "v_max_speed", IMPULSE_JUMP_START_V_MAX_SPEED, IMPULSE_JUMP_END_V_MAX_SPEED, IMPULSE_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				
				start_tweens()
			else:
				v_vel = JUMP_V_SPEED * Vector2(0, -1)
		elif can_wall_jump:
			if velocity[1] < -MIN_IMPULSE_V_SPEED:
				v_vel = WALL_JUMP_IMPULSE_V_SPEED * Vector2(0, -1)
				h_vel = WALL_JUMP_IMPULSE_H_SPEED * wall_normal
				
				h_acceleration_tween.interpolate_property(self, "h_acceleration", WALL_JUMP_IMPULSE_START_H_ACCELERATION, WALL_JUMP_IMPULSE_END_H_ACCELERATION, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				h_speed_tween.interpolate_property(self, "h_max_speed", WALL_JUMP_IMPULSE_START_H_MAX_SPEED, WALL_JUMP_IMPULSE_END_H_MAX_SPEED, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				gravity_tween.interpolate_property(self, "gravity", WALL_JUMP_IMPULSE_START_GRAVITY, WALL_JUMP_IMPULSE_END_GRAVITY, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				v_speed_tween.interpolate_property(self, "v_max_speed", WALL_JUMP_IMPULSE_START_V_MAX_SPEED, WALL_JUMP_IMPULSE_END_V_MAX_SPEED, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				
				start_tweens()
			else:
				v_vel = WALL_JUMP_V_SPEED * Vector2(0, -1)
				h_vel = WALL_JUMP_H_SPEED * wall_normal
				if velocity[1] < 0:
					v_vel += Vector2(0, velocity[1]) * SMALL_VERTICAL_WALL_JUMP_MULTIPLIER
				
				h_acceleration_tween.interpolate_property(self, "h_acceleration", WALL_JUMP_START_H_ACCELERATION, WALL_JUMP_END_H_ACCELERATION, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				h_speed_tween.interpolate_property(self, "h_max_speed", WALL_JUMP_START_H_MAX_SPEED, WALL_JUMP_END_H_MAX_SPEED, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				gravity_tween.interpolate_property(self, "gravity", WALL_JUMP_START_GRAVITY, WALL_JUMP_END_GRAVITY, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				v_speed_tween.interpolate_property(self, "v_max_speed", WALL_JUMP_START_V_MAX_SPEED, WALL_JUMP_END_V_MAX_SPEED, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
				
				start_tweens()
		elif hook_fixed:
			hook_fixed = false
			hook.start_return()
			
			v_vel = HOOK_JUMP_V_SPEED * Vector2(0, -1)
			
			if hook.player_is_almost_tensioned():
				h_vel += Vector2((velocity * SWING_SPEED_MULTIPLIER)[0], 0)
				v_vel += Vector2(0, (velocity * SWING_SPEED_MULTIPLIER)[1])
		
		h_vel += add_h_vel
		v_vel += add_v_vel
	
	if Input.is_action_just_pressed("hook"):
		if has_hook:
			has_hook = false
			
			animation_player.force_play_animation("spin")
			
			var add_h_vel = Vector2(0, 0)
			var add_v_vel = Vector2(0, 0)
			
			if can_jump or can_wall_jump:
				var add_mov_plat_vel = get_moving_platform_speed()
				add_h_vel = Vector2(add_mov_plat_vel[0], 0)
				add_v_vel = Vector2(0, add_mov_plat_vel[1])
			
			if can_jump:
				can_jump = false
				
				jump_sound.play()
				
				v_vel = SPIN_JUMP_V_SPEED * Vector2(0, -1)
				
				add_jump_smoke()
			elif can_wall_jump:
				if velocity[1] < -MIN_IMPULSE_V_SPEED:
					v_vel = WALL_SPIN_JUMP_IMPULSE_V_SPEED * Vector2(0, -1)
					h_vel = WALL_SPIN_JUMP_IMPULSE_H_SPEED * wall_normal
					
					h_acceleration_tween.interpolate_property(self, "h_acceleration", WALL_JUMP_IMPULSE_START_H_ACCELERATION, WALL_JUMP_IMPULSE_END_H_ACCELERATION, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					h_speed_tween.interpolate_property(self, "h_max_speed", WALL_JUMP_IMPULSE_START_H_MAX_SPEED, WALL_JUMP_IMPULSE_END_H_MAX_SPEED, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					gravity_tween.interpolate_property(self, "gravity", WALL_JUMP_IMPULSE_START_GRAVITY, WALL_JUMP_IMPULSE_END_GRAVITY, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					v_speed_tween.interpolate_property(self, "v_max_speed", WALL_JUMP_IMPULSE_START_V_MAX_SPEED, WALL_JUMP_IMPULSE_END_V_MAX_SPEED, WALL_JUMP_IMPULSE_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					
					start_tweens()
				else:
					v_vel = WALL_SPIN_JUMP_V_SPEED * Vector2(0, -1)
					h_vel = WALL_SPIN_JUMP_H_SPEED * wall_normal
					if velocity[1] < 0:
						v_vel += Vector2(0, velocity[1]) * SMALL_VERTICAL_WALL_JUMP_MULTIPLIER
					
					h_acceleration_tween.interpolate_property(self, "h_acceleration", WALL_JUMP_START_H_ACCELERATION, WALL_JUMP_END_H_ACCELERATION, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					h_speed_tween.interpolate_property(self, "h_max_speed", WALL_JUMP_START_H_MAX_SPEED, WALL_JUMP_END_H_MAX_SPEED, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					gravity_tween.interpolate_property(self, "gravity", WALL_JUMP_START_GRAVITY, WALL_JUMP_END_GRAVITY, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					v_speed_tween.interpolate_property(self, "v_max_speed", WALL_JUMP_START_V_MAX_SPEED, WALL_JUMP_END_V_MAX_SPEED, WALL_JUMP_TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
					
					start_tweens()
			
			h_vel += add_h_vel
			v_vel += add_v_vel
			
			var hook_dir = dir
			if hook_dir == Vector2(0, 0):
				if sprite.flip_h:
					hook_dir = Vector2(-1, 0)
				else:
					hook_dir = Vector2(1, 0)
			
			hook = Hook.instance()
			hook.position = position
			hook.dir = hook_dir
			parent.add_child(hook)
		
		else:
			if hook.is_fixed():
				can_jump = false
				
				burst_sound.play()
				create_afterimage()
				camera.add_trauma(camera.SHAKE_MEDIUM)
				
				hook.burst()
				hook.start_burst_return()
				
				var burst_vector = hook.get_burst_dir() * BURST_SPEED
				
				var burst_particles = BurstParticles.instance()
				burst_particles.set_direction(burst_vector.normalized())
				burst_particles.position = position
				parent.add_child(burst_particles)
				
				h_vel = Vector2(burst_vector[0], 0)
				v_vel = Vector2(0, burst_vector[1])
				
				h_acceleration_tween.interpolate_property(self, "h_acceleration", BURST_START_H_ACCELERATION, BURST_END_H_ACCELERATION, BURST_TWEEN_TIME, Tween.TRANS_CIRC, Tween.EASE_IN)
				h_speed_tween.interpolate_property(self, "h_max_speed", BURST_START_H_MAX_SPEED, BURST_END_H_MAX_SPEED, BURST_TWEEN_TIME, Tween.TRANS_CIRC, Tween.EASE_IN)
				gravity_tween.interpolate_property(self, "gravity", BURST_START_GRAVITY, BURST_END_GRAVITY, BURST_TWEEN_TIME, Tween.TRANS_CIRC, Tween.EASE_IN)
				v_speed_tween.interpolate_property(self, "v_max_speed", BURST_START_V_MAX_SPEED, BURST_END_V_MAX_SPEED, BURST_TWEEN_TIME, Tween.TRANS_CIRC, Tween.EASE_IN)
				
				start_tweens()
				
				if burst_vector[0] > 0:
					sprite.flip_h = false
				else:
					sprite.flip_h = true
				
				burst_vector[0] = abs(burst_vector[0])
				
				var angle = burst_vector.angle()
				
				if angle < 3 * PI / 8 and angle > PI / 8:
					animation_player.force_play_animation("burst_diagonal_down")
				elif angle < PI / 8 and angle > -PI / 8 :
					animation_player.force_play_animation("burst_forward")
				elif angle < -PI / 8 and angle > -3 * PI / 8:
					animation_player.force_play_animation("burst_diagonal_up")
				else: 
					animation_player.force_play_animation("burst_up")
				
				is_swinging = false
	
	# VELOCITY
	velocity = Vector2(h_vel[0], v_vel[1])
	
	if is_swinging:
		velocity = hook.project_velocity_to_chain(velocity)
	
	if not has_hook:
		velocity += delta * CHAIN_ELASTIC_CONSTANT * hook.get_deformation_vector()
	
	if is_sliding_on_moving_plat:
		velocity[0] = moving_plat_vel[0]
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if get_slide_count() >= 1:
		var collision = get_slide_collision(get_slide_count() - 1)
		
		if collision:
			if collision.collider.get_collision_layer_bit(1):
				death(collision.normal)


func _animation_process():
	var wall_normal = raycast_controller.get_wall_normal()
	
	if dir.dot(velocity) > 0 or not is_on_floor():
		if velocity[0] > TURN_SPEED_MINIMUM:
			sprite.flip_h = false
		elif velocity[0] < -TURN_SPEED_MINIMUM:
			sprite.flip_h = true
	
	if is_on_floor():
		if abs(velocity[0]) < WALK_MIN_SPEED:
			animation_player.try_play_animation("idle")
		else:
			animation_player.try_play_animation("walk")
	elif ((is_on_wall() and velocity[1] > 0) or wall_normal.dot(raycast_controller.get_moving_plat_velocity()) > 0) or not has_hook and raycast_controller.is_on_wall():
		animation_player.try_play_animation("wall_hit")
		
		var dir = wall_normal
		if dir[0] > 0:
			sprite.flip_h = false
		elif dir[0] < 0:
			sprite.flip_h = true
	else:
		if velocity[1] < -AIR_SPEED_INTERVAL:
			animation_player.try_play_animation("jump")
		elif velocity[1] > AIR_SPEED_INTERVAL:
			animation_player.try_play_animation("fall")
		else:
			animation_player.try_play_animation("air")
	
	if animation_player.current_animation == "walk":
		if not walk_sound.is_playing():
			walk_sound.play()
	else:
		walk_sound.stop()


func force_recover_hook():
	if not has_hook:
		hook.get_collected()
		recover_hook()


func recover_hook():
	has_hook = true
	hook = null


func get_shot(dir, pos):
	position = parent.get_true_position(pos)
	
	
	velocity = dir * BURST_SPEED
	
	if dir[0] > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	dir[0] = abs(dir[0])
	
	var angle = dir.angle()
	
	if angle < 3 * PI / 8 and angle > PI / 8:
		animation_player.force_play_animation("burst_diagonal_down")
	elif angle < PI / 8 and angle > -PI / 8 :
		animation_player.force_play_animation("burst_forward")
	elif angle < -PI / 8 and angle > -3 * PI / 8:
		animation_player.force_play_animation("burst_diagonal_up")
	else: 
		animation_player.force_play_animation("burst_up")


func death(v):
	death_sound.play()
	camera.add_trauma(camera.SHAKE_SMALL)
	
	is_dead = true
	animation_player.force_play_animation("dead")
	
	h_acceleration_tween.remove_all()
	h_acceleration_tween.interpolate_property(self, "position", position, position + v * DEATH_DISTANCE, DEATH_EXPLODE_TIME, Tween.TRANS_EXPO, Tween.EASE_OUT)
	h_acceleration_tween.start()
	
	yield(h_acceleration_tween, "tween_completed")
	
	camera.add_trauma(camera.SHAKE_BIG)
	sprite.hide()
	var death_particles = DeathParticles.instance()
	death_particles.position = position
	parent.add_child(death_particles)
	
	afterimage_timer.start(DEATH_LINGER_TIME)
	
	yield(afterimage_timer, "timeout")
	
	parent.respawn()


func _cutscene_process():
	move_and_slide(velocity)


func set_dialogue_target(target):
	dialogue_target = target


func delete_dialogue_target():
	dialogue_target = null


func start_cutscene_and_walk_to(x_pos, turned_to_right_after = true):
	start_cutscene()
	if not on_floor:
		yield(cutscene_tween, "tween_completed")
	cutscene_walk_to_x(x_pos, turned_to_right_after)


func start_cutscene():
	walk_sound.stop()
	
	dir = Vector2(0, 0)
	
	if hook != null:
		hook.get_collected()
	
	cutscene_mode = true
	
	if not on_floor:
		animation_player.force_play_animation("fall")
		
		var floor_distance = raycast_controller.get_distance_to_floor()
		var final_velocity = Vector2(0, sqrt(pow(velocity[1], 2) + 2 * CUTSCENE_GRAVITY * floor_distance) + CUTSCENE_EXTRA_FALLING_SPEED)
		var tween_time = (-velocity[1] + final_velocity[1])/(CUTSCENE_GRAVITY)
		cutscene_tween.interpolate_property(self, "velocity", Vector2(0, velocity[1]), final_velocity, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
		cutscene_tween.start()
		
		yield(cutscene_tween, "tween_completed")
		
		velocity = Vector2(0, 0)
		
		animation_player.force_play_animation("land")
		land_sound.play()
		on_floor = true
		add_jump_smoke()
	animation_player.try_play_animation("idle")


func cutscene_walk_to_x(x_pos, turned_to_right_after = true):
	walk_sound.play()
	
	if position[0] != x_pos:
		animation_player.force_play_animation("walk")
		if position[0] - x_pos > 0:
			sprite.flip_h = true
		elif position[0] - x_pos < 0:
			sprite.flip_h = false
	
	cutscene_tween.interpolate_property(self, "position", position, Vector2(x_pos, position[1]), abs(x_pos - position[0])/H_MAX_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	cutscene_tween.start()
	
	yield(cutscene_tween, "tween_completed")
	
	walk_sound.stop()
	animation_player.play("idle")
	velocity = Vector2(0, 0)
	sprite.flip_h = not turned_to_right_after


func end_cutscene():
	coyote_time_timer.start(CUTSCENE_END_WAIT_TIME)
	yield(coyote_time_timer, "timeout")
	
	can_jump = true
	cutscene_mode = false
