extends Node2D

export (Script) var SaveGameClass
export (PackedScene) var MainMenu
export (PackedScene) var MainLoader
export (PackedScene) var DialogueBox

var save_vars = ["Transition", "transition_code", "collectible_flags", "world_flags", "is_light_enabled"]

var main_menu
var current_save
var save_name
var dialogue_dict

func _ready():
	var file = File.new()
	file.open("res://dialogue/en.json", file.READ)
	dialogue_dict = parse_json(file.get_as_text())
	
	back_to_menu()


func back_to_menu():
	main_menu = MainMenu.instance()
	add_child(main_menu)


func back_to_credits():
	back_to_menu()
	main_menu.go_to_credits()


func spawn_level(sv_name):
	save_name = sv_name
	load_game()
	
	var main_loader_scene = MainLoader.instance()
	add_child(main_loader_scene)
	main_loader_scene.get_node("Viewport/MainLoader").spawn(current_save.Transition, current_save.transition_code)


# SAVE FUNCTIONS
func validate_save(save):
	for v in save_vars:
		if save.get(v) == null:
			return false
	
	var base_save = SaveGameClass.new()
	
	for i in base_save.collectible_flags.keys():
		if not save.collectible_flags.has(i):
			save.collectible_flags[i] = base_save.collectible_flags[i]
	
	for i in base_save.world_flags.keys():
		if not save.world_flags.has(i):
			save.world_flags[i] = base_save.world_flags[i]
	
	save_game()
	
	return true


func save_game():
	var dir = Directory.new()
	if not dir.dir_exists("res://saves/"):
		dir.make_dir_recursive("res://saves/")
	
	ResourceSaver.save("res://saves/" + save_name + ".tres", current_save)


func load_game():
	var dir = Directory.new()
	if not dir.file_exists("res://saves/" + save_name + ".tres"):
		current_save = SaveGameClass.new()
		save_game()
	current_save = load("res://saves/" + save_name + ".tres")
	
	if not validate_save(current_save):
		return false
	return true


func update_room(Transition, transition_code):
	current_save.Transition = Transition
	current_save.transition_code = transition_code


func update_collectible_flag(flag_name, bool_value):
	current_save.collectible_flags[flag_name] = bool_value
	save_game()


func update_world_flag(flag_name, bool_value):
	current_save.world_flags[flag_name] = bool_value
	save_game()


func update_dialogue_flag(flag_name, bool_value):
	current_save.dialogue_flags[flag_name] = bool_value
	save_game()


func get_collectible_flag(flag_name):
	if not flag_name in current_save.collectible_flags:
		current_save.collectible_flags[flag_name] = false
	
	return current_save.collectible_flags[flag_name]


func get_world_flag(flag_name):
	if not flag_name in current_save.world_flags:
		current_save.world_flags[flag_name] = false
	
	return current_save.world_flags[flag_name]


func get_dialogue_flag(flag_name):
	if not flag_name in current_save.dialogue_flags:
		current_save.dialogue_flags[flag_name] = false
	
	return current_save.dialogue_flags[flag_name]


func get_dialogue(dialogue_name):
	if dialogue_dict.has(dialogue_name):
		return dialogue_dict[dialogue_name]
	return dialogue_dict["fallback"]


func is_light_enabled():
	return current_save.is_light_enabled


func create_dialogue_box(speaker):
	var cameras = get_tree().get_nodes_in_group("Camera")
	if len(cameras) > 0:
		var dialogue_box = DialogueBox.instance()
		
		dialogue_box.position = (speaker.get_global_position() - (cameras[0].get_camera_screen_center() + Vector2(-192, -108))) * 5
		dialogue_box.speaker = speaker
		dialogue_box.camera = cameras[0]
		
		add_child(dialogue_box)
		return dialogue_box
	return null
