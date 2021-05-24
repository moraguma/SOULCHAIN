extends Area2D

export (PackedScene) var Chain
export (Gradient) var GRADIENT

export var COLLECTION_DISTANCE = 100
export var testing_mode = false

const MAX_CHAINS = 40

var collection_started = false
var player = null
var debug_mode = false
var true_position = position

var total_chains = 0
var chain_list = []
var clockwise_list = []

var parent
onready var drawing_line = $DrawingLine
onready var sprite = $Sprite
onready var eye_sprite = $EyeSprite


func _ready():
	if get_tree().get_root().has_node("Main"):
		parent = get_parent().get_parent().get_parent()
	else:
		parent = get_parent().get_parent()
		debug_mode = true


func _physics_process(delta):	
	if collection_started:
		_chain_process()
		_line_draw_process()
		_length_process()
	
	_animation_process()


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
	
	chain_list[0].position = true_position
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
		if total_chains > MAX_CHAINS:
			get_collected()
			return
		
		chain_list[i].force_raycast_update()
		
		if chain_list[i].is_colliding():
			var original_pos = chain_list[i].position
			var original_vector = chain_list[i].cast_to
			var final_pos = chain_list[i].position + chain_list[i].cast_to 
			
			var col_tilemap = chain_list[i].get_collider()
			
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
		drawing_line.add_point(i.position - true_position)
	
	drawing_line.add_point(player.position - true_position)


func _animation_process():
	sprite.play("idle")
	eye_sprite.play("idle")


func get_total_length():
	var length = 0
	
	for i in chain_list:
		length += i.cast_to.distance_to(Vector2(0, 0))
	
	if testing_mode:
		print(length)
	return length


func _length_process():
	var length = get_total_length()
	
	if length < COLLECTION_DISTANCE:
		var color = GRADIENT.interpolate(get_total_length() / COLLECTION_DISTANCE)
		
		drawing_line.material.set_shader_param("color", Vector3(color.r, color.g, color.b))
	else:
		get_collected()


func get_collected():
	for i in chain_list:
		i.queue_free()
	
	queue_free()


func start_collection(body):
	if not collection_started:
		if debug_mode:
			true_position = position
		else:
			true_position = parent.get_true_position(position)
		
		collection_started = true
		player = body
		
		var chain = Chain.instance()
		chain.position = true_position
		chain.cast_to = player.position - true_position
		
		parent.add_child(chain)
		
		chain_list.append(chain)
		total_chains = 1


func reset():
	if collection_started:
		collection_started = false
		player = null
		
		for i in chain_list:
			i.queue_free()
		
		drawing_line.clear_points()
		
		chain_list = []
		clockwise_list = []
		total_chains = 0
