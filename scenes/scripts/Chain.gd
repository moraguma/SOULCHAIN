extends RayCast2D

var sticker = null
var last_stick_pos = Vector2(0, 0)


func _ready():
	if sticker != null:
		last_stick_pos = sticker.position


func _physics_process(delta):
	if sticker != null:
		if last_stick_pos != sticker.position:
			position += sticker.position - last_stick_pos
			last_stick_pos = sticker.position
