extends Node2D

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
	var left_check = left_feet_hit_trigger.is_colliding()
	var right_check = right_feet_hit_trigger.is_colliding()
	
	if left_check or right_check:
		var moving_plat
		if left_check:
			left_feet_hit_trigger.get_collider().start_moving()
		else:
			right_feet_hit_trigger.get_collider().start_moving()


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
