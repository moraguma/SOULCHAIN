extends Area2D


export var flag = ""
export var group = ""


const SOUL_STICK_POS = Vector2(0, 14)
const TWEEN_TIME = 1


var global_top_position
var active = false
var debug_mode = false


var parent

onready var chain_bottom = $ChainBottom
onready var chain_top = $ChainTop
onready var drawing_line = $DrawingLine
onready var tween = $Tween


func _ready():
	add_to_group("PullableChain" + group)
	
	if get_tree().get_root().has_node("Main"):
		parent = get_parent().get_parent()
	else:
		parent = get_parent()
		debug_mode = true
	
	if not debug_mode:
		
		if flag != "" and not debug_mode:
			if parent.get_world_flag(flag):
				active = true
				position = position + chain_bottom.position
	
	global_top_position = $ChainTop.get_global_position()
	
	drawing_line.add_point(Vector2(0, 0))
	
	var new_pos = Vector2(0, 0)
	
	if active:
		new_pos = -chain_bottom.position + chain_top.position
	else:
		new_pos = chain_top.position
	
	drawing_line.add_point(new_pos)


func _physics_process(delta):
	_line_draw_process()


func _line_draw_process():
	var new_pos = Vector2(0, 0)
	
	if active:
		new_pos = -chain_bottom.position + chain_top.position
	else:
		new_pos = chain_top.position
	
	drawing_line.set_point_position(1, new_pos)


func stick(body):
	if not body.is_returning:
		body.force_stick(self, get_global_position() + SOUL_STICK_POS)


func burst():
	if not active and not tween.is_active():
		active = true
		
		get_tree().call_group("Gate" + group, "activate")
		
		if flag != "" and not debug_mode:
			parent.update_world_flag(flag, true)
		
		tween.interpolate_property(self, "position", position, position + chain_bottom.position, TWEEN_TIME, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		tween.start()


func back_to_normal():
	if active and not tween.is_active():
		active = false
		
		tween.interpolate_property(self, "position", position, position - chain_bottom.position, TWEEN_TIME, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		tween.start()


func reset():
	if flag == "":
		if active:
			active = false
			position = position - chain_bottom.position
