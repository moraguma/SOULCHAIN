tool
extends RichTextEffect
class_name Surge


const MIN_TIME = 0.12





var bbcode := "surge"

var starting_times = {}

func _process_custom_fx(char_fx):
	var time = char_fx.env.get("time", 0.15)
	var height = char_fx.env.get("height", 2)
	
	var a = -4 * height / pow(time, 2)
	var b = 4 * height / time
	
	var t
	if not char_fx.visible:
		t = char_fx.elapsed_time
	
	if char_fx.visible and not starting_times.has(char_fx.absolute_index) and char_fx.elapsed_time > MIN_TIME:
		starting_times[char_fx.absolute_index] = char_fx.elapsed_time
	
	if starting_times.has(char_fx.absolute_index):
		var true_time = char_fx.elapsed_time - starting_times[char_fx.absolute_index]
		char_fx.offset = Vector2(0, -clamp(a * pow(true_time, 2) + b * true_time, 0, height))
	
	return true
