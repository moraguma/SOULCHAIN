extends AnimationPlayer


# CAN ONLY BE INTERRUPTED BY INDICATED ANIMATIONS
const VERY_LIMITED_ANIMATIONS = {"spin": ["wall_hit"], "burst_up": [], "burst_diagonal_up": [], "burst_diagonal_down": [], "burst_forward": [], "dead": []}
# CANNOT BE INTERRUPTED BY INDICATED ANIMATIONS
const LIMITED_ANIMATIONS = {"wall_slide":["wall_hit"], "land": ["idle", "walk"], "husk_wall_slide": ["wall_hit"], "husk_land":["idle", "walk"]}


onready var player = get_parent()


func choose_anim(anim):
	if not player.has_hook:
		if get_animation("husk_" + anim) != null:
			return "husk_" + anim
	return anim


func try_play_animation(anim):
	var can_play = true
	if current_animation in LIMITED_ANIMATIONS:
		can_play = not anim in LIMITED_ANIMATIONS[current_animation]
	elif current_animation in VERY_LIMITED_ANIMATIONS:
		can_play = anim in VERY_LIMITED_ANIMATIONS[current_animation]
	
	if can_play:
		play(choose_anim(anim))


func force_play_animation(anim):
	play(anim)
