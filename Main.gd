extends Node2D

export (PackedScene) var MainMenu
export (PackedScene) var MainLoader

var main_menu
var main_loader

func _ready():
	back_to_menu()


func back_to_menu():
	main_menu = MainMenu.instance()
	add_child(main_menu)


func back_to_credits():
	back_to_menu()
	main_menu.go_to_credits()


func spawn_level(Level, placement, music, start_pos):
	var main_loader = MainLoader.instance()
	add_child(main_loader)
	main_loader.spawn(Level, placement, music, start_pos)
