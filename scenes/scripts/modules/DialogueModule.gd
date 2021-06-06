extends Node2D


export (String) var dialogue_name = "fallback"
export (Dictionary) var references = {}
export (bool) var player_facing_right_on_dialogue = true

var pos = 0
var dialogue = {}
var dialogue_box = null
var player = null
var choice_dict = {}
var is_choosing = false
var is_playing = false
var player_in_range = false


onready var main = get_tree().get_root().get_node("Main")
onready var talking_position = $TalkingPosition


func _ready():
	dialogue = main.get_dialogue(dialogue_name)


func _input(event):
	if not is_choosing:
		if Input.is_action_just_pressed("speak") and player != null and dialogue_box.can_skip():
			if player.on_floor:
				if not is_playing:
					activate()
				else:
					next_line()


func make_choice(choice):
	is_choosing = false
	
	pos = choice_dict["skip" + str(choice + 1)]
	
	next_line()


func next_line():
	var new_line
	var dialogue_playing = false
	
	while not dialogue_playing:
		if not dialogue.has(str(pos)):
			deactivate()
			break
		
		new_line = dialogue[str(pos)]
		
		match new_line["type"]:
			"dialogue":
				dialogue_box.display_text(new_line["content"], new_line["speed"])
				pos = int(pos) + 1
				
				dialogue_playing = true
			"choice":
				choice_dict = new_line
				var choices = []
				var i = 1
				while new_line.has(str(i)):
					choices.append(new_line[str(i)])
					i += 1
				
				dialogue_box.start_choice(choices, self)
				
				dialogue_playing = true
			"flag_checker":
				if main.get_dialogue_flag(new_line["flag"]):
					pos = new_line["skip_if_true"]
				else:
					pos = new_line["skip_if_false"]
			"flag_updater":
				main.update_dialogue_flag(new_line["flag"], new_line["value"])
				pos += 1
			"skipper":
				pos = new_line["skip_to"]
			"speaker_changer":
				var new_speaker = null
				if new_line["speaker"] == "self":
					new_speaker = self
				elif new_line["speaker"] == "player":
					new_speaker = player.dialogue_sticker
				else:
					new_speaker = get_node(new_line["speaker"])
				
				dialogue_box.transfer_to(new_speaker)
				yield(dialogue_box.scale_tween, "tween_completed")
				
				pos = int(pos) + 1


func activate():
	pos = 1
	is_playing = true
	
	player.start_cutscene_and_walk_to(talking_position.get_global_position()[0], player_facing_right_on_dialogue)
	
	if dialogue_box == null:
		dialogue_box = main.create_dialogue_box(self)
	
	next_line()


func deactivate():
	dialogue_box.back_to_normal()
	player.end_cutscene()
	
	is_playing = false
	
	if not player_in_range:
		player_exited(player)


func player_entered(body):
	player = body
	player_in_range = true
	
	body.set_dialogue_target(self)
	dialogue_box = main.create_dialogue_box(self)


func player_exited(body):
	player_in_range = false
	
	if not is_playing:
		player = null
		
		body.delete_dialogue_target()
		dialogue_box.delete()
