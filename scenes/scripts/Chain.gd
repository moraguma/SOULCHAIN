extends RayCast2D


var active = false


onready var line = $Line2D


func _ready():
	line.add_point(position)
	line.add_point(position + cast_to)


func _process(delta):
	if active:
		line.set_point_position(1, position + cast_to)


func activate():
	active = true


func deactivate():
	active = false
