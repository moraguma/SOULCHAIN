extends Node2D


export (PackedScene) var SelectionNode


const BOX_HEIGHT = 116
const Y_SCALE_PER_LINE = 0.4
const POS_MOD_PER_SCALE = 24
const X_SCALE = 3
const BOX_BOTTOM_POS = Vector2(0, 40)

const TIME_PER_CHARACTER_VERY_SLOW = 0.2
const TIME_PER_CHARACTER_SLOW = 0.03
const TIME_PER_CHARACTER_MEDIUM = 0.012
const TIME_PER_CHARACTER_FAST = 0.005

const SELECTION_NODE_BASE_POS = Vector2(0, -40)
const SPACE_PER_SELECTION_NODE = 24

const TEXT_RENDER_TIME = 0.1
const BOX_TRANSITION_TIME = 0.2
const RENDER_TIME = 0.2
const CONNECTOR_RENDER_TIME = 0.6

var BASE_CONTENT_HEIGHT = 0
var BASE_TEXT_Y = 0

var is_choosing = false
var choice = 0
var choices = []
var choice_selection_nodes = []
var choice_callback = null

var can_skip = true
var speaker = null
var camera = null


onready var connector = $Connector
onready var box = $Box
onready var text_label = $RichTextLabel
onready var text_show_tween = $TextShowTween
onready var scale_tween = $ScaleTween
onready var connector_scale_tween = $ConnectorScaleTween
onready var position_tween = $PositionTween
onready var timer = $Timer


func _ready():
	BASE_CONTENT_HEIGHT = text_label.margin_bottom - text_label.margin_top - 4
	BASE_TEXT_Y = text_label.rect_position[1]
	appear()

func _process(delta):
	position = (speaker.get_global_position() - (camera.get_camera_screen_center() + Vector2(-192, -108))) * 5


func _input(event):
	if is_choosing:
		if Input.is_action_just_pressed("dialogue_left") and choice > 0:
			choice_selection_nodes[choice].desselect()
			
			choice -= 1
			choice_selection_nodes[choice].select()
			display_text("[/surge]" + choices[choice], "medium")
		elif Input.is_action_just_pressed("dialogue_right") and choice < len(choices) - 1:
			choice_selection_nodes[choice].desselect()
			
			choice += 1
			choice_selection_nodes[choice].select()
			display_text("[/surge]" + choices[choice], "medium")
		elif Input.is_action_just_pressed("speak"):
			for node in choice_selection_nodes:
				node.delete()
			choice_callback.make_choice(choice)
			is_choosing = false
			can_skip = false


func back_to_normal():
	text_label.bbcode_text = ""
	
	position_tween.interpolate_property(box, "position", box.position, Vector2(0, 0), RENDER_TIME, Tween.TRANS_BACK, Tween.EASE_OUT)
	scale_tween.interpolate_property(box, "scale", box.scale, Vector2(1, 1), RENDER_TIME, Tween.TRANS_BACK, Tween.EASE_OUT)
	connector_scale_tween.interpolate_property(connector, "scale", connector.scale, Vector2(1, 1), RENDER_TIME, Tween.TRANS_BACK, Tween.EASE_OUT)
	
	position_tween.start()
	scale_tween.start()
	connector_scale_tween.start()


func get_bb_codeless_text_size(text):
	var true_length = len(text)
	
	var i = 0
	while i < len(text):
		if text[i] == "[":
			true_length -= 1
			while text[i] != "]":
				i += 1
				true_length -= 1
		i += 1
	
	return true_length


func start_choice(options, callback):
	is_choosing = true
	
	choice = 0
	choices = options
	choice_callback = callback
	choice_selection_nodes = []
	
	var first_selection_node_pos = SELECTION_NODE_BASE_POS + Vector2(-SPACE_PER_SELECTION_NODE * (len(choices) - 1) / 2, 0)
	for i in range(len(choices)):
		var new_selection_node = SelectionNode.instance()
		new_selection_node.position = first_selection_node_pos + i * Vector2(SPACE_PER_SELECTION_NODE, 0)
		choice_selection_nodes.append(new_selection_node)
		
		add_child(new_selection_node)
	
	choice_selection_nodes[0].select()
	display_text("[/surge]" + choices[0], "medium")


func display_text(text, speed):
	can_skip = false
	scale_tween.stop_all()
	position_tween.stop_all()
	
	text_label.bbcode_text = "[center][surge]" + text
	text_label.rect_position[1] = 9999
	
	timer.start(TEXT_RENDER_TIME)
	yield(timer, "timeout")
	
	var line_count = text_label.get_visible_line_count()
	text_label.percent_visible = 0
	
	text_label.rect_position[1] = BASE_TEXT_Y - (line_count - 1) * BASE_CONTENT_HEIGHT
	
	var box_new_scale_y = 1 + (Y_SCALE_PER_LINE * (line_count - 1))
	
	if Vector2(X_SCALE, box_new_scale_y) != box.scale:
		scale_tween.interpolate_property(box, "scale", box.scale, Vector2(X_SCALE, box_new_scale_y), BOX_TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		position_tween.interpolate_property(box, "position", box.position, Vector2(box.position[0], (box_new_scale_y - 1) * 24), BOX_TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		
		scale_tween.start()
		position_tween.start()
		
		yield(scale_tween, "tween_completed")
	
	var text_speed
	match speed:
		"very slow":
			text_speed = TIME_PER_CHARACTER_VERY_SLOW
		"slow":
				text_speed = TIME_PER_CHARACTER_SLOW
		"medium":
				text_speed = TIME_PER_CHARACTER_MEDIUM
		"fast":
				text_speed = TIME_PER_CHARACTER_FAST
		
	text_show_tween.interpolate_property(text_label, "percent_visible", 0, 1, get_bb_codeless_text_size(text) * text_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	text_show_tween.start()
	
	yield(text_show_tween, "tween_completed")
	
	can_skip = true


func can_skip():
	return can_skip and not is_choosing


func appear():
	scale_tween.stop_all()
	position_tween.stop_all()
	connector_scale_tween.stop_all()
	
	position_tween.interpolate_property(box, "position", BOX_BOTTOM_POS, Vector2(0, 0), RENDER_TIME, Tween.TRANS_BACK, Tween.EASE_OUT)
	scale_tween.interpolate_property(box, "scale", Vector2(0.3, 0.3), Vector2(1, 1), RENDER_TIME, Tween.TRANS_BACK, Tween.EASE_OUT)
	connector_scale_tween.interpolate_property(connector, "scale", Vector2(0, 0), Vector2(1, 1), CONNECTOR_RENDER_TIME, Tween.TRANS_BACK, Tween.EASE_OUT)
	
	position_tween.start()
	scale_tween.start()
	connector_scale_tween.start()


func disappear():
	scale_tween.stop_all()
	position_tween.stop_all()
	connector_scale_tween.stop_all()
	text_label.bbcode_text = ""
	
	position_tween.interpolate_property(box, "position", box.position, BOX_BOTTOM_POS, RENDER_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
	scale_tween.interpolate_property(box, "scale", box.scale, Vector2(0.3, 0.3), RENDER_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
	connector_scale_tween.interpolate_property(connector, "scale", Vector2(1, 1), Vector2(0, 0), RENDER_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
	
	position_tween.start()
	scale_tween.start()
	connector_scale_tween.start()


func transfer_to(new_speaker):
	disappear()
	yield(scale_tween, "tween_completed")
	
	speaker = new_speaker
	
	appear()


func delete():
	disappear()
	yield(scale_tween, "tween_completed")
	
	queue_free()
