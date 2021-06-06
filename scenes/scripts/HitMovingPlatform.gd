extends "res://scenes/scripts/UniformMovingPlatform.gd"


const DELAY_MOVEMENT_TIME = 0.3


var moving = false
onready var timer = $Timer


func start_moving():
	if not moving:
		moving = true
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		camera.add_trauma(camera.SHAKE_MEDIUM)
		
		timer.start(DELAY_MOVEMENT_TIME)
		yield(timer, "timeout")
		
		animation_player.play("move")


func stop_moving():
	moving = false


func reset():
	if moving:
		animation_player.advance(99)
		animation_player.stop()
		stop_moving()
