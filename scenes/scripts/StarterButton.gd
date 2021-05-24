extends Button


export (PackedScene) var Level
export (String) var save_name


func start_level():
	get_parent().get_parent().start_level(save_name)
