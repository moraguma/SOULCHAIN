extends KinematicBody2D


const TWEEN_TIME = 0.7


export var flag = ""
export var group = ""


var active = false
var debug_mode = false


var parent
onready var activate_position = $ActivatePosition
onready var tween = $Tween


func _ready():
	add_to_group("Gate" + group)
	
	if get_tree().get_root().has_node("Main"):
		parent = get_parent().get_parent()
	else:
		parent = get_parent()
		debug_mode = true
	
	if not debug_mode:
		
		if flag != "" and not debug_mode:
			if parent.get_world_flag(flag):
				active = true
				position = position + activate_position.position


func activate():
	if not active and not tween.is_active():
		active = true
		
		tween.interpolate_property(self, "position", position, position + activate_position.position, TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()


func back_to_normal():
	if active and not tween.is_active():
		active = false
		
		tween.interpolate_property(self, "position", position, position - activate_position.position, TWEEN_TIME, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		tween.start()


func reset():
	if flag == "":
		if active:
			active = false
			position = position - activate_position.position
