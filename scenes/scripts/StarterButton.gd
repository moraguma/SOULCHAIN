extends Button


export (PackedScene) var Level


func start_level(music, position):
	get_parent().get_parent().start_level(Level, music, position)
