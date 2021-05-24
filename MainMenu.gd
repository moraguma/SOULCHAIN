extends Node2D

export (PackedScene) var FirstLevel

enum PLACEMENT {right, left}
export (PLACEMENT) var first_level_placement = PLACEMENT.left

onready var main = get_parent()

func _ready():
	pass


func _input(event):
	if Input.is_action_just_pressed("menu"):
		quit_game()


func quit_game():
	get_tree().quit()


func start_level(save_name):
	main.spawn_level(save_name)
	queue_free()


