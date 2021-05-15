extends AnimationPlayer


const LIMITED_ANIMATIONS = {"stick_horizontal_plane":["land_horizontal_plane"], "stick_vertical_plane": ["land_vertical_plane"]}


func try_play_animation(anim):
	var can_play = true
	if current_animation in LIMITED_ANIMATIONS:
		can_play = not anim in LIMITED_ANIMATIONS[current_animation]
	
	if can_play:
		play(anim)


func force_play_animation(anim):
	play(anim)
