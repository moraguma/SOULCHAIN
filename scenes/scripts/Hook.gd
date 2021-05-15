extends KinematicBody2D

export (PackedScene) var Chain 
export (PackedScene) var HookHitParticles

# ------------------------------------------------
# MOVEMENT CONSTANTS

const BASE_SPEED = 10
const RETURN_SPEED = 10
const RETURN_COLLIDE_DISTANCE = 5
const COLLECT_DISTANCE = 15
const MAX_CHAINS = 40
const MIN_SIZE_FOR_REAL_DIR = 8
# ------------------------------------------------

# ------------------------------------------------
# VARIABLES

var clockwise_list = []
var chain_list = []
var total_chains = 1

var can_get_shot = true
var is_returning = false
var active = true

var last_cast
var defined_length = false
var max_length = 99999

var dir = Vector2(0, 0)
var collision = null
# ------------------------------------------------

# ------------------------------------------------
# NODES

onready var parent = get_parent()
var player
var camera
onready var drawing_line = $DrawingLine
onready var animation_player = $AnimationPlayer
onready var raycast_controller = $RaycastController
onready var sprite = $Sprite
onready var light = $Light
var tilemap = null

onready var throw_sound = $ThrowSound
onready var hit_sound = $HitSound
onready var pull_sound = $PullSound
# ------------------------------------------------


func _ready():
	throw_sound.play()
	
	if parent.name != "Base":
		player = get_parent().get_player()
	else:
		player = get_parent().get_node("Player")
	camera = player.get_node("Camera")
	
	var chain = Chain.instance()
	chain.position = position
	chain.cast_to = player.position - position
	
	parent.add_child(chain)
	
	chain_list.append(chain)


func _physics_process(delta):
	if active:
		if not is_returning:
			if not defined_length:
				_movement_process()
		else:
			_return_process()
		
		if total_chains > 0:
			_chain_process()
		
		_animation_process()


func _process(delta):
	_line_draw_process()


func _movement_process():
	var check
	
	if parent.name == "Base":
		check = true
	else: 
		if parent.is_inside(position):
			check = true
	
	if check:
		var og_pos = position
		var temp_collision = move_and_collide(dir * BASE_SPEED)
		
		var og_cast = chain_list[0].cast_to
		
		if temp_collision:
			camera.add_trauma(camera.SHAKE_SMALL)
			
			tilemap = temp_collision.collider
			
			if tilemap.can_stick(temp_collision, position):
				dir = Vector2(0, 0)
				
				if not defined_length:
					hit_sound.play()
					
					max_length = get_total_length()
					defined_length = true
					
					collision = temp_collision
			else:
				var hook_hit_particles = HookHitParticles.instance()
				hook_hit_particles.position = temp_collision.position
				hook_hit_particles.set_direction(temp_collision.normal)
				parent.add_child(hook_hit_particles)
				
				start_return()
	else:
		start_return()


func distance_to_raycast(pos, cast_to, v):
	var x0 = v[0]
	var y0 = v[1]
	var x1 = pos[0]
	var y1 = pos[1]
	var x2 = pos[0] + cast_to[0]
	var y2 = pos[1] + cast_to[1]
	
	return abs((x2 - x1) * (y1 - y0) - (x1 - x0) * (y2 - y1))/sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))


func _chain_process():
	var og_raycast_info = []
	for i in range(total_chains):
		og_raycast_info.append([chain_list[i].position, chain_list[i].cast_to])
	
	chain_list[0].position = position
	for i in range(total_chains - 1):
		chain_list[i].cast_to = chain_list[i + 1].position - chain_list[i].position
	chain_list[total_chains - 1].cast_to = player.position - chain_list[total_chains - 1].position
	
	var i = 0
	
	while i < total_chains - 1:
		var original_vector = chain_list[i].cast_to
		chain_list[i].cast_to = chain_list[i + 1].position + chain_list[i + 1].cast_to - chain_list[i].position
		chain_list[i].force_raycast_update()
		
		if not chain_list[i].is_colliding() and original_vector.angle_to(chain_list[i].cast_to) > 0 != clockwise_list[i]:
			var del_chain = chain_list[i + 1]
			chain_list.remove(i + 1)
			total_chains -= 1
			del_chain.hide()
			del_chain.queue_free()
			
			clockwise_list.remove(i)
		else:
			chain_list[i].cast_to = original_vector
			chain_list[i].force_raycast_update()
		i += 1
	
	i = 0
	
	while i < total_chains:
		
		chain_list[i].force_raycast_update()
		
		if i > MAX_CHAINS:
			get_collected(true)
			return
		
		if chain_list[i].is_colliding():
			var original_pos = chain_list[i].position
			var original_vector = chain_list[i].cast_to
			var final_pos = chain_list[i].position + chain_list[i].cast_to 
			
			var col_tilemap = chain_list[i].get_collider()
			
			#var possible_corners = col_tilemap.get_corner_positions(chain_list[i].get_collision_point())
			var possible_corners = col_tilemap.get_possible_corners(chain_list[i].get_collision_point(), chain_list[i].get_collision_normal())
			
			var corner_pos = Vector2(0, 0)
			if len(possible_corners) > 0:
				var z = 0
				while z < len(possible_corners):
					if possible_corners[z] == chain_list[i].position:
						possible_corners.remove(z)
					else:
						z += 1
				
				if len(possible_corners) > 0:
					corner_pos = possible_corners[0]
					
					for j in range(1, len(possible_corners)):
						if distance_to_raycast(og_raycast_info[i][0], og_raycast_info[i][1], possible_corners[j]) < distance_to_raycast(og_raycast_info[i][0], og_raycast_info[i][1], corner_pos):
							corner_pos = possible_corners[j]
			
			chain_list[i].cast_to = corner_pos - chain_list[i].position
			
			var new_chain = Chain.instance()
			new_chain.position = corner_pos
			new_chain.cast_to = final_pos - corner_pos
			
			parent.add_child(new_chain)
			new_chain.force_raycast_update()
			
			chain_list.insert(i + 1, new_chain)
			clockwise_list.insert(i, chain_list[i].cast_to.angle_to(chain_list[i + 1].cast_to) > 0)
			og_raycast_info.insert(i + 1, [chain_list[i + 1].position, chain_list[i + 1].cast_to])
			total_chains += 1
		i += 1


func _line_draw_process():
	drawing_line.clear_points()
	
	for i in chain_list:
		drawing_line.add_point(i.position - position)
	
	drawing_line.add_point(player.position - position)


func _return_process():
	var new_cast = chain_list[0].cast_to
	
	if new_cast.dot(last_cast) < 0:
		var del_chain = chain_list.pop_front()
		del_chain.hide()
		del_chain.queue_free()
		total_chains -= 1
		
		if total_chains > 0:
			last_cast = chain_list[0].cast_to
		else:
			get_collected()
	
	if total_chains <= 1 and (position - player.position).distance_to(Vector2(0, 0)) <= COLLECT_DISTANCE:
		get_collected()
	
	else:
		last_cast = new_cast
	
	if total_chains > 0:
		dir = chain_list[0].cast_to.normalized()
		move_and_collide(RETURN_SPEED * dir)


func _animation_process():
	if is_returning or not defined_length:
		var angle = dir.angle()
		
		if -7 * PI / 8 <= angle and angle < -5 * PI / 8:
			animation_player.try_play_animation("shoot_diagonal")
			sprite.flip_h = true
			sprite.flip_v = false
		elif -5 * PI / 8 <= angle and angle < -3 * PI / 8:
			animation_player.try_play_animation("shoot_vertical")
			sprite.flip_h = false
			sprite.flip_v = false
		elif -3 * PI / 8 <= angle and angle < -1 * PI / 8:
			animation_player.try_play_animation("shoot_diagonal")
			sprite.flip_h = false
			sprite.flip_v = false
		elif -1 * PI / 8 <= angle and angle < 1 * PI / 8:
			animation_player.try_play_animation("shoot_horizontal")
			sprite.flip_h = false
			sprite.flip_v = false
		elif 1 * PI / 8 <= angle and angle < 3 * PI / 8:
			animation_player.try_play_animation("shoot_diagonal")
			sprite.flip_h = false
			sprite.flip_v = true
		elif 3 * PI / 8 <= angle and angle < 5 * PI / 8:
			animation_player.try_play_animation("shoot_vertical")
			sprite.flip_h = false
			sprite.flip_v = true
		elif 5 * PI / 8 <= angle and angle < 7 * PI / 8:
			animation_player.try_play_animation("shoot_diagonal")
			sprite.flip_h = true
			sprite.flip_v = true
		else:
			animation_player.try_play_animation("shoot_horizontal")
			sprite.flip_h = true
			sprite.flip_v = false
	else:
		var normal = raycast_controller.get_wall_normal()
		
		if normal[0] == 0:
			animation_player.try_play_animation("land_horizontal_plane")
			
			if normal[1] > 0:
				sprite.flip_v = false
			elif normal[1] < 0:
				sprite.flip_v = true
		elif normal[1] == 0:
			animation_player.try_play_animation("land_vertical_plane")
			
			if normal[0] > 0:
				sprite.flip_h = false
			elif normal[0] < 0:
				sprite.flip_h = true

func get_total_length():
	var length = 0
	
	for i in chain_list:
		length += i.cast_to.distance_to(Vector2(0, 0))
	
	return length


# Returns true if the player is tensioning the rope, false otherwise
func player_is_tensioned():
	if total_chains > 0:
		return get_total_length() >= max_length and player.velocity.dot(chain_list[total_chains - 1].cast_to) > 0
	return false


# Returns the vector that represents the chain's deformation
func get_deformation_vector():
	var deformation = get_total_length() - max_length
	
	if defined_length and deformation > 0:
		return -chain_list[total_chains - 1].cast_to.normalized() * deformation
	return Vector2(0, 0)


# Returns the giver velocity projected on the 90 degrees rotated version of the 
# last chain's raycast
func project_velocity_to_chain(vel):
	return vel.project(chain_list[total_chains - 1].cast_to.rotated(PI/2))


# Returns true if the player can jump and false otherwise
func is_fixed():
	return defined_length and not is_returning


# Returns the normalized vector that represents the direction the player should 
# burst to
func get_burst_dir():
	if get_total_length() > MIN_SIZE_FOR_REAL_DIR:
		return -chain_list[total_chains - 1].cast_to.normalized()
	else:
		if player.is_on_floor():
			var mod_v = Vector2(-chain_list[total_chains - 1].cast_to[0], 0).normalized()
			return mod_v
		else:
			return Vector2(0, -1)


func burst():
	tilemap.dehook_tiles(collision, position)


func get_shot(new_dir, pos):
	position = parent.get_true_position(pos)
	dir = new_dir
	
	defined_length = false
	is_returning = false
	
	set_collision_mask_bit(0, true)
	set_collision_mask_bit(1, true)


func get_collected(force = false):
	active = false
	
	for i in chain_list:
		i.queue_free()
	
	player.recover_hook()
	
	queue_free()


func start_burst_return():
	start_return()


func start_return():
	pull_sound.play()
	
	is_returning = true
	last_cast = chain_list[0].cast_to
	
	set_collision_mask_bit(0, false)
	set_collision_mask_bit(1, false)
	set_collision_layer_bit(4, false)


func turn_on_light():
	light.show()
