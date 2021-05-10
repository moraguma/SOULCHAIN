extends Node2D


onready var up = $Up
onready var right = $Right
onready var down = $Down
onready var left = $Left


func get_wall_normal():
	if up.is_colliding():
		return Vector2(0, 1)
	elif right.is_colliding():
		return Vector2(-1, 0)
	elif down.is_colliding():
		return Vector2(0, -1)
	elif left.is_colliding():
		return Vector2(1, 0)
	
	return Vector2(0, 0)
