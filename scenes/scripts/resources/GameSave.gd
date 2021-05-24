extends Resource

export (PackedScene) var Transition = load("res://scenes/levels/somewhereold/SleepwalkersPlateau.tscn")
export (String) var transition_code = "Left"

export var collectible_flags = {
	"1":false,
	"2":false
}

export var world_flags = {
	"test":false
}
