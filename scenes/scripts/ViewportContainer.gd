extends ViewportContainer


export (Color) var white
export (Color) var shadow_color


const TRANSITION_TIME = 0.5


var debug_mode = false


var main = null
onready var tween = $ShadowTween


func _ready():
	if get_tree().get_root().has_node("Main"):
		main = get_tree().get_root().get_node("Main")
		if main.is_light_enabled():
			material.set_shader_param("shadow_color", shadow_color)
		else:
			material.set_shader_param("shadow_color", white)
	else:
		debug_mode = true


func turn_on():
	tween.stop_all()
	tween.interpolate_property(material, "shader_param/shadow_color", white, shadow_color, TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func turn_off():
	tween.stop_all()
	tween.interpolate_property(material, "shader_param/shadow_color", shadow_color, white, TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
