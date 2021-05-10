extends Node2D

export (PackedScene) var Player

enum PLACEMENT {right, left}

const TRANSITION_TIME = 0.4
const CAMERA_TRANSITION_TIME = 0.4
const VERTICAL_TOLLERANCE = 90

const MUSIC_VOLUME = -10
const MUSIC_TRANSITION_TIME = 2

var total_deaths = 0

var starting_position
var current_area
var respawn_position
var player 
var sprite
var camera
var sprite_flip_h

onready var start_time = OS.get_ticks_msec()

onready var tween = $Tween
onready var camera_tween_up = $CameraTweenUp
onready var camera_tween_right = $CameraTweenRight
onready var camera_tween_down = $CameraTweenDown
onready var camera_tween_left = $CameraTweenLeft

onready var music_noir = $MusicNoir
onready var music_sleeves = $MusicSleeves
onready var tween_noir = $NoirTween
onready var tween_sleeves = $SleevesTween

func spawn(Transition, placement, music, starting_pos):
	starting_position = starting_pos
	
	player = Player.instance()
	sprite = player.get_node("Sprite")
	camera = player.get_node("Camera")
	
	add_child(player)
	
	current_area = Transition.instance()
	add_child(current_area)
	current_area.initialize_transitions()
	
	match placement:
		PLACEMENT.left:
			respawn_position = current_area.get_node("TransitionAreaLeft").spawn_point
			sprite_flip_h = false
		PLACEMENT.right:
			respawn_position = current_area.get_node("TransitionAreaRight").spawn_point
			sprite_flip_h = true
	
	camera.limit_left = current_area.min_x
	camera.limit_right = current_area.max_x
	camera.limit_top = current_area.min_y
	camera.limit_bottom = current_area.max_y
	
	player.position = respawn_position
	sprite.flip_h = sprite_flip_h
	
	player.update_tilemap()
	
	match music:
		"noir":
			music_noir.volume_db = MUSIC_VOLUME
			music_noir.play()
		"sleeves":
			music_sleeves.volume_db = MUSIC_VOLUME
			music_sleeves.play()

func transition(Transition, placement):
	var past_area = current_area
	current_area = Transition.instance()
	
	add_child(current_area)
	
	match placement:
		PLACEMENT.left:
			current_area.position = past_area.position + past_area.get_node("TransitionAreaLeft").position - current_area.get_node("TransitionAreaRight").position
			
			respawn_position = current_area.position + current_area.get_node("TransitionAreaRight").spawn_point
			sprite_flip_h = true
			
			camera.limit_left = current_area.position[0] + current_area.min_x
		PLACEMENT.right:
			current_area.position = past_area.position + past_area.get_node("TransitionAreaRight").position - current_area.get_node("TransitionAreaLeft").position
			
			respawn_position = current_area.position + current_area.get_node("TransitionAreaLeft").spawn_point
			sprite_flip_h = false
			
			camera.limit_right = current_area.position[0] + current_area.max_x
	
	player.is_transitioning = true
	tween.interpolate_property(player, "position", player.position, Vector2(respawn_position[0], player.position[1]), TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera_tween_up.interpolate_property(camera, "limit_top", camera.limit_top, current_area.position[1] + current_area.min_y, CAMERA_TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera_tween_right.interpolate_property(camera, "limit_right", camera.limit_right, current_area.position[0] + current_area.max_x, CAMERA_TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera_tween_down.interpolate_property(camera, "limit_bottom", camera.limit_bottom, current_area.position[1] + current_area.max_y, CAMERA_TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera_tween_left.interpolate_property(camera, "limit_left", camera.limit_left, current_area.position[0] + current_area.min_x, CAMERA_TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	camera_tween_up.start()
	camera_tween_right.start()
	camera_tween_down.start()
	camera_tween_left.start()
	
	tween.start()
	
	yield(get_tree().create_timer(TRANSITION_TIME), "timeout")
	player.is_transitioning = false
	
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
	player.update_tilemap()


func get_tilemap():
	return current_area.get_node("Tiles")


func get_player():
	return player


func is_inside(pos):
	return pos[0] > camera.limit_left and pos[0] < camera.limit_right and pos[1] < camera.limit_bottom + VERTICAL_TOLLERANCE


func back_to_menu():
	get_parent().back_to_menu()
	queue_free()


func back_to_credits():
	get_parent().call_deferred("back_to_credits")
	queue_free()


func start_sleeves_music():
	if music_noir.playing:
		music_sleeves.volume_db = -80
		music_sleeves.play()
		
		tween_noir.interpolate_property(music_noir, "volume_db", MUSIC_VOLUME, -80, MUSIC_TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween_sleeves.interpolate_property(music_sleeves, "volume_db", -80, MUSIC_VOLUME, MUSIC_TRANSITION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween_noir.start()
		tween_sleeves.start()
		
		yield(get_tree().create_timer(MUSIC_TRANSITION_TIME), "timeout")
		
		music_noir.stop()


func get_starting_position():
	return starting_position


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
