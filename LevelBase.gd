extends Node2D

export var min_x = 0
export var max_x = 384
export var min_y = 0
export var max_y = 216


func initialize_transitions():
	for node in $Transitions.get_children():
		node.Transition = load(node.transition_path)
		node.monitorable = true
		node.monitoring = true


func go_to_credits(_body):
	get_parent().back_to_credits()
