extends "res://scenes/scripts/UniformMovingPlatform.gd"


const DELAY_MOVEMENT_TIME = 0.4


var moving = false
onready var timer = $Timer
onready var camera = get_tree().get_nodes_in_group("Camera")[0]


func start_moving():
	if not moving:
		moving = true
		camera.add_trauma(camera.SHAKE_MEDIUM)
		
		timer.start(DELAY_MOVEMENT_TIME)
		yield(timer, "timeout")
		
		animation_player.play("move")


func stop_moving():
	moving = false
