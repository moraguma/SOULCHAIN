extends Polygon2D


const SURGE_TIME = 0.3
const DISSAPEAR_TIME = 0.1
const NORMAL_SCALE = Vector2(0.5, 0.5)


onready var selected_node = $SelectedNode
onready var tween = $Tween
onready var spawn_tween = $SpawnTween


func _ready():
	spawn_tween.interpolate_property(self, "scale", Vector2(0, 0), NORMAL_SCALE, SURGE_TIME, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	spawn_tween.start()


func select():
	tween.stop_all()
	tween.interpolate_property(selected_node, "scale", selected_node.scale, Vector2(1.1, 1.1), SURGE_TIME, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()


func desselect():
	tween.stop_all()
	tween.interpolate_property(selected_node, "scale", selected_node.scale, Vector2(0, 0), DISSAPEAR_TIME, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()


func delete():
	desselect()
	yield(tween, "tween_completed")
	queue_free()
