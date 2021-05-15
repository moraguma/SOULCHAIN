extends Node2D

export (PackedScene) var Player

const TRANSITION_TIME = 0.5

const BOTTOM_TOLLERANCE = 30
const TOP_TOLLERANCE = 100
const LEFT_TOLLERANCE = 30
const RIGHT_TOLLERANCE = 30

var total_deaths = 0

var current_area
var respawn_position
var player 
var sprite
var camera
var sprite_flip_h

onready var start_time = OS.get_ticks_msec()

onready var tween = $Tween
onready var camera_x_tween = $CameraXTween
onready var camera_y_tween = $CameraYTween

func initialize_player():
	#TEMPORARY
	
	player.turn_on_light()

func spawn(Transition, transition_code):
	player = Player.instance()
	sprite = player.get_node("Sprite")
	camera = player.get_node("Camera")
	
	add_child(player)
	
	initialize_player()
	
	current_area = Transition.instance()
	add_child(current_area)
	current_area.initialize_transitions()
	
	var current_transition = current_area.get_node("Transitions").get_node("TransitionArea" + transition_code)
	
	respawn_position = current_area.position + current_transition.spawn_point
	sprite_flip_h = current_transition.facing_right_on_respawn
	
	camera.limit_left = current_area.min_x
	camera.limit_right = current_area.max_x
	camera.limit_top = current_area.min_y
	camera.limit_bottom = current_area.max_y
	
	player.position = respawn_position
	sprite.flip_h = sprite_flip_h
	
	player.update_tilemap()

func transition(Transition, transition_code, transition_area):
	var past_area = current_area
	current_area = Transition.instance()
	
	add_child(current_area)
	
	var new_transition_area = current_area.get_node("Transitions").get_node("TransitionArea" + transition_code)
	current_area.position = past_area.position + transition_area.position - new_transition_area.position
	respawn_position = current_area.position + new_transition_area.spawn_point
	sprite_flip_h = transition_area.facing_right_on_respawn
	
	if past_area.position[1] > current_area.position[1]:
		camera_y_tween.interpolate_property(camera, "limit_bottom", past_area.position[1] + 216, current_area.position[1] + current_area.max_y, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		camera.limit_top = current_area.position[1] + current_area.min_y
	else:
		camera_y_tween.interpolate_property(camera, "limit_top", past_area.position[1] + past_area.max_y - 216, current_area.position[1] + current_area.min_y, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		camera.limit_bottom = current_area.position[1] + current_area.max_y
	
	if past_area.position[0] > current_area.position[0]:
		camera_x_tween.interpolate_property(camera, "limit_right", past_area.position[0] + 384, current_area.position[0] + current_area.max_x, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		camera.limit_left = current_area.position[0] + current_area.min_x
	else:
		camera_x_tween.interpolate_property(camera, "limit_left", past_area.position[0] + past_area.max_x - 384, current_area.position[0] + current_area.min_x, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		camera.limit_right = current_area.position[0] + current_area.max_x
	
	player.is_transitioning = true
	
	var new_player_position = player.position
	if transition_area.is_horizontal:
		if abs(transition_area.position[0] - past_area.min_x) < abs(transition_area.position[0] - past_area.max_x):
			new_player_position += transition_area.transition_distance * Vector2(-1, 0)
		else:
			new_player_position += transition_area.transition_distance * Vector2(1, 0)
	else:
		if abs(transition_area.position[1] - past_area.min_y) < abs(transition_area.position[1] - past_area.max_y):
			 new_player_position += transition_area.transition_distance * Vector2(0, -1)
		else:
			new_player_position += transition_area.transition_distance * Vector2(0, 1)
	
	tween.interpolate_property(player, "position", player.position, new_player_position, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
	var old_drag_margin_left = camera.drag_margin_left
	var old_drag_margin_right = camera.drag_margin_right
	var old_drag_margin_top = camera.drag_margin_top
	var old_drag_margin_bottom = camera.drag_margin_bottom
	
	camera.drag_margin_left = 1
	camera.drag_margin_right = 1
	camera.drag_margin_top = 1
	camera.drag_margin_bottom = 1
	
	tween.start()
	camera_x_tween.start()
	camera_y_tween.start()
	
	yield(tween, "tween_all_completed")
	player.is_transitioning = false
	
	camera.drag_margin_left = old_drag_margin_left
	camera.drag_margin_right = old_drag_margin_right
	camera.drag_margin_top = old_drag_margin_top
	camera.drag_margin_bottom = old_drag_margin_bottom
	
	past_area.queue_free()
	current_area.initialize_transitions()
	
	player.force_recover_hook()
	player.update_tilemap()


func respawn():
	total_deaths += 1
	
	var del_player = player
	player = Player.instance()
	
	del_player.force_recover_hook()
	
	camera = player.get_node("Camera")
	sprite = player.get_node("Sprite")
	
	var old_camera = del_player.get_node("Camera")
	
	camera.limit_left = old_camera.limit_left
	camera.limit_top = old_camera.limit_top
	camera.limit_right = old_camera.limit_right
	camera.limit_bottom = old_camera.limit_bottom
	
	del_player.queue_free()
	
	player.position = respawn_position
	sprite.flip_h = sprite_flip_h
	
	add_child(player)
	
	initialize_player()
	
	player.update_tilemap()


func get_tilemaps():
	return current_area.get_node("Tiles").get_children()


func get_player():
	return player


func is_inside(pos):
	return pos[0] > camera.limit_left - LEFT_TOLLERANCE and pos[0] < camera.limit_right + RIGHT_TOLLERANCE and pos[1] < camera.limit_bottom + BOTTOM_TOLLERANCE and pos[1] > camera.limit_top - TOP_TOLLERANCE


func back_to_menu():
	get_parent().back_to_menu()
	queue_free()


func back_to_credits():
	get_parent().call_deferred("back_to_credits")
	queue_free()


# Returns a printable string that shows the elapsed time in hours:minutes:seconds
func get_elapsed_time():
	var final_time = (OS.get_ticks_msec() - start_time) / 1000
	
	var hours = int(final_time / 3600)
	final_time -= hours * 3600
	
	var minutes = int(final_time/60)
	final_time -= minutes * 60
	
	var seconds = int(final_time)
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func get_total_deaths():
	return "%03d" % [total_deaths]


func get_true_position(pos):
	return current_area.position + pos
