extends Particles2D

func _ready():
	emitting = true
	
	var timer = $FreeTimer
	
	timer.start(lifetime * (1 + process_material.lifetime_randomness))
	yield(timer, "timeout")
	queue_free()


func set_direction(v):
	var true_v = Vector3(v[0], v[1], 0)
	
	process_material.set("direction", true_v)
