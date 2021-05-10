extends Node2D

export var path_left = ""
export var path_right = "res://scenes/levels/Level2.tscn"

export var min_x = 0
export var max_x = 384
export var min_y = 0
export var max_y = 216


func initialize_transitions():
	$TransitionAreaLeft.Transition = load(path_left)
	$TransitionAreaRight.Transition = load(path_right)
	
	$TransitionAreaLeft.monitoring = true
	$TransitionAreaRight.monitoring = true


func start_sleeves_music(_body):
	get_parent().start_sleeves_music()


func go_to_credits(_body):
	get_parent().back_to_credits()
