extends Camera2D

# SCREENSHAKE CONSTANTS
const SHAKE_MIN = 0.1
const SHAKE_SMALL = 0.2
const SHAKE_MEDIUM = 0.4
const SHAKE_BIG = 0.6

const DECAY = 0.9
const MAX_OFFSET = Vector2(16, 9)
const MAX_ROLL = 0.15
const TRAUMA_POWER = 2


const REGION_LOCK_TRANSITION_TIME = 1.5
const TRANSITION_TIME = 0.5

# SCREENSHAKE VARIABLES
var trauma = 0.0

var area_limit_bottom = 0
var area_limit_top = 0
var area_limit_left = 0
var area_limit_right = 0

onready var x_limit_tween = $XLimitTween
onready var y_limit_tween = $YLimitTween
onready var h_offset_tween = $HOffsetTween
onready var v_offset_tween = $VOffsetTween
onready var noise = OpenSimplexNoise.new()
var noise_y = 0

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2


func _process(delta):
	if trauma:
		trauma = max(trauma - DECAY * delta, 0)
		shake()


func add_trauma(amount):
	trauma = min(trauma + amount * (1.0 - trauma), 1.0)


func shake():
	var amount = pow(trauma, TRAUMA_POWER)
	
	noise_y += 1
	
	rotation = MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset[0] = MAX_OFFSET[0] * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset[1] = MAX_OFFSET[1] * amount * noise.get_noise_2d(noise.seed * 3, noise_y)


func set_area_limit(l_bottom, l_top, l_left, l_right):
	x_limit_tween.stop_all()
	y_limit_tween.stop_all()
	
	var camera_screen_center = get_camera_screen_center()
	
	if area_limit_bottom > l_bottom:
		y_limit_tween.interpolate_property(self, "limit_bottom", camera_screen_center[1] + 108, l_bottom, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		limit_top = l_top
	else:
		y_limit_tween.interpolate_property(self, "limit_top", camera_screen_center[1] - 108, l_top, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		limit_bottom = l_bottom
	
	if area_limit_right > l_right:
		x_limit_tween.interpolate_property(self, "limit_right", camera_screen_center[0] + 192, l_right, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		limit_left = l_left
	else:
		x_limit_tween.interpolate_property(self, "limit_left", camera_screen_center[0] - 192, l_left, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		limit_right = l_right
	
	x_limit_tween.start()
	y_limit_tween.start()
	
	area_limit_bottom = l_bottom
	area_limit_top = l_top
	area_limit_left = l_left
	area_limit_right = l_right


func limit_lock_region_enter(l_bottom, l_top, l_left, l_right, effective_transition_time = REGION_LOCK_TRANSITION_TIME):
	x_limit_tween.stop_all()
	y_limit_tween.stop_all()
	
	var camera_screen_center = get_camera_screen_center()
	
	if l_bottom < camera_screen_center[1] + 108:
		y_limit_tween.interpolate_property(self, "limit_bottom", camera_screen_center[1] + 108, l_bottom, effective_transition_time , Tween.TRANS_CIRC, Tween.EASE_OUT)
		limit_top = l_top
	else:
		y_limit_tween.interpolate_property(self, "limit_top", camera_screen_center[1] - 108, l_top, effective_transition_time , Tween.TRANS_CIRC, Tween.EASE_OUT)
		limit_bottom = l_bottom
	y_limit_tween.start()
	
	if l_right < camera_screen_center[0] + 192:
		x_limit_tween.interpolate_property(self, "limit_right", camera_screen_center[0] + 192, l_right, effective_transition_time , Tween.TRANS_CIRC, Tween.EASE_OUT)
		limit_left = l_left
	else:
		x_limit_tween.interpolate_property(self, "limit_left", camera_screen_center[0] - 192, l_left, effective_transition_time , Tween.TRANS_CIRC, Tween.EASE_OUT)
		limit_right = l_right
	x_limit_tween.start()


func limit_lock_region_exit():
	x_limit_tween.stop_all()
	y_limit_tween.stop_all()
	
	limit_bottom = area_limit_bottom
	limit_top = area_limit_top
	limit_left = area_limit_left
	limit_right = area_limit_right
