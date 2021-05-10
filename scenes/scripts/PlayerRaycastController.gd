extends Node2D

onready var up_right = $UpRight
onready var up_left = $UpLeft
onready var down_right = $DownRight
onready var down_left = $DownLeft
onready var left_feet = $LeftFeet
onready var right_feet = $RightFeet


func is_on_wall():
	return up_right.is_colliding() or down_right.is_colliding() or up_left.is_colliding() or down_left.is_colliding()


func is_on_floor():
	return left_feet.is_colliding() or right_feet.is_colliding()


func get_wall_normal():
	var d = Vector2(0, 0)
	
	if up_right.is_colliding() or down_right.is_colliding():
		d += Vector2(-1, 0)
	
	if up_left.is_colliding() or down_left.is_colliding():
		d += Vector2(1, 0)
	
	return d
