extends Node2D

export (PackedScene) var FirstLevel

enum PLACEMENT {right, left}
export (PLACEMENT) var first_level_placement = PLACEMENT.left

onready var main = get_parent()
onready var menu = $Main
onready var level_select = $LevelSelect
onready var credits = $Credits

func _ready():
	$AnimationPlayer.play("idle")
	
	go_to_menu()


func _input(event):
	if Input.is_action_just_pressed("menu"):
		quit_game()


func quit_game():
	get_tree().quit()


func hide_all():
	menu.hide()
	level_select.hide()
	credits.hide()


func go_to_menu():
	hide_all()
	menu.show()


func go_to_level_select():
	hide_all()
	level_select.show()


func go_to_credits():
	hide_all()
	credits.show()


func start_level(Level, music, start_pos):
	main.spawn_level(Level, PLACEMENT.left, music, start_pos)
	queue_free()


