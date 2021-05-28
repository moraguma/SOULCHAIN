extends Particles2D

var velocity = Vector2(0, 0)

func _ready():
	emitting = true
	
	var timer = $FreeTimer
	
	timer.start(lifetime * (1 + process_material.lifetime_randomness))
	yield(timer, "timeout")
	queue_free()


func _physics_process(delta):
	position += velocity * delta


func set_direction(v):
	var true_v = Vector3(v[0], v[1], 0)
	
	process_material.set("direction", true_v)
