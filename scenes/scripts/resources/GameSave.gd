extends Resource

export (PackedScene) var Transition = load("res://scenes/levels/somewhereold/SleepwalkersPlateau.tscn")
export (String) var transition_code = "Left"
export (bool) var is_light_enabled = true

export var collectible_flags = {
	"SO1": false
}

export var world_flags = {
	"test": false
}

export var dialogue_flags = {
	"test": false
}
