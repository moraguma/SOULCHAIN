extends Sprite

const TOTAL_TIME = 0.5

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	
	timer.start(TOTAL_TIME)


func _process(delta):
	material.set_shader_param("alpha", timer.time_left/TOTAL_TIME * 0.8)


func timer_end():
	queue_free()
