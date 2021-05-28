extends Light2D


const MAX_ENERGY = 0.8
const TRANSITION_TIME = 0.5


var debug_mode = false


var main = null
onready var tween = $Tween


func _ready():
	if get_tree().get_root().has_node("Main"):
		main = get_tree().get_root().get_node("Main")
		if main.is_light_enabled():
			energy = MAX_ENERGY
		else:
			energy = 0
	else:
		debug_mode = true


func turn_on():
	tween.stop_all()
	tween.interpolate_property(self, "energy", 0, MAX_ENERGY, TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func turn_off():
	tween.stop_all()
	tween.interpolate_property(self, "energy", MAX_ENERGY, 0, TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
