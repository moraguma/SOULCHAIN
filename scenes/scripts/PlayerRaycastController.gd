extends Node2D

onready var player = get_parent()

onready var up_right = $UpRight
onready var up_left = $UpLeft
onready var down_right = $DownRight
onready var down_left = $DownLeft
onready var left_feet = $LeftFeet
onready var right_feet = $RightFeet
onready var moving_plat_left = $MovingPlatDetectorLeft
onready var moving_plat_right = $MovingPlatDetectorRight
onready var moving_plat_down = $MovingPlatDetectorDown

onready var left_feet_hit_trigger = $LeftFeetHitTrigger
onready var right_feet_hit_trigger = $RightFeetHitTrigger

func _physics_process(delta):
	if left_feet_hit_trigger.is_colliding():
		var body = left_feet_hit_trigger.get_collider()
		if body.has_method("start_moving"):
			body.start_moving()
	elif right_feet_hit_trigger.is_colliding():
		var body = right_feet_hit_trigger.get_collider()
		if body.has_method("start_moving"):
			body.start_moving()


func is_on_wall():
	return up_right.is_colliding() or down_right.is_colliding() or up_left.is_colliding() or down_left.is_colliding()


func is_on_floor():
	return (left_feet.is_colliding() or right_feet.is_colliding()) and not (moving_plat_right.is_colliding() or moving_plat_left.is_colliding())


func get_wall_normal():
	var d = Vector2(0, 0)
	
	if up_right.is_colliding() or down_right.is_colliding():
		d += Vector2(-1, 0)
	
	if up_left.is_colliding() or down_left.is_colliding():
		d += Vector2(1, 0)
	
	return d


func get_moving_plat_velocity():
	var moving_plats = []
	var moving_plats_order = [moving_plat_left, moving_plat_right, moving_plat_down]
	
	for i in moving_plats_order:
		if i.is_colliding():
			var collider = i.get_collider()
			if not collider in moving_plats:
				moving_plats.append(collider)
	
	var total_velocity = Vector2(0, 0)
	for i in moving_plats:
		total_velocity += i.get_transfer_velocity()
	
	return total_velocity


# Returns distance to floor from feet
func get_distance_to_floor():
	var og_cast_to = left_feet.cast_to
	
	left_feet.cast_to = Vector2(0, 1000)
	right_feet.cast_to = Vector2(0, 1000)
	left_feet.force_raycast_update()
	right_feet.force_raycast_update()
	
	var left_distance = 9999
	var right_distance = 9999
	
	if left_feet.is_colliding():
		left_distance = abs((left_feet.get_collision_point() - (player.position + position + left_feet.position))[1])
	if right_feet.is_colliding():
		right_distance = abs((right_feet.get_collision_point() - (player.position + position + right_feet.position))[1])
	
	var result = min(left_distance, right_distance)
	
	left_feet.cast_to = og_cast_to
	right_feet.cast_to = og_cast_to
	left_feet.force_raycast_update()
	right_feet.force_raycast_update()
	
	return result
