extends Area2D

var Transition

export (String) var transition_path
export (String) var transition_code
export var facing_right_on_respawn = true
export var is_horizontal = true
export var transition_distance = 32

const HORIZONTAL_SPAWN_VECTOR = Vector2(64, 0)
const VERTICAL_SPAWN_VECTOR = Vector2(0, 64)

var spawn_point

onready var main_loader = get_parent().get_parent().get_parent()

func _ready():
	spawn_point = position + $SpawnPoint.position


func transition(body):
	main_loader.call_deferred("transition", Transition, transition_code, self)



