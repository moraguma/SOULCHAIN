extends Area2D

var Transition

enum PLACEMENT {right, left}
export (PLACEMENT) var placement = PLACEMENT.right

const HORIZONTAL_SPAWN_VECTOR = Vector2(64, 0)
const VERTICAL_SPAWN_VECTOR = Vector2(0, 64)

var spawn_point

onready var main_loader = get_parent().get_parent()

func _ready():
	match placement:
		PLACEMENT.right:
			spawn_point = position - HORIZONTAL_SPAWN_VECTOR + VERTICAL_SPAWN_VECTOR
		PLACEMENT.left:
			spawn_point = position + HORIZONTAL_SPAWN_VECTOR + VERTICAL_SPAWN_VECTOR


func transition(body):
	main_loader.call_deferred("transition", Transition, placement)



