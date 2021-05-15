extends Node2D

export (PackedScene) var MainMenu
export (PackedScene) var MainLoader
export (PackedScene) var TEMPLEVEL

var main_menu
var main_loader

func _ready():
	spawn_level(TEMPLEVEL, "Left")
	
	#back_to_menu()


func back_to_menu():
	main_menu = MainMenu.instance()
	add_child(main_menu)


func back_to_credits():
	back_to_menu()
	main_menu.go_to_credits()


func spawn_level(Level, transition_code):
	var main_loader = MainLoader.instance()
	add_child(main_loader)
	main_loader.spawn(Level, transition_code)
