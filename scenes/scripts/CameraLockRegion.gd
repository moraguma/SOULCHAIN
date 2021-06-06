extends Area2D


export var rel_l_top = 0
export var rel_l_bottom = 216
export var rel_l_left = 0
export var rel_l_right = 384
export var transition_time = -1.0


func region_enter(body):
	var global_pos = get_parent().position + position
	
	var true_l_top = rel_l_top + global_pos[1]
	var true_l_bottom = rel_l_bottom + global_pos[1]
	var true_l_left = rel_l_left + global_pos[0]
	var true_l_right = rel_l_right + global_pos[0]
	
	if transition_time != -1:
		body.camera.limit_lock_region_enter(true_l_bottom, true_l_top, true_l_left, true_l_right, transition_time)
	else:
		body.camera.limit_lock_region_enter(true_l_bottom, true_l_top, true_l_left, true_l_right)


func region_exit(body):
	body.camera.limit_lock_region_exit()
