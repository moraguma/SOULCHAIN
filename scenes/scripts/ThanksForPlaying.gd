extends Node2D

onready var loader = get_parent().get_parent()

onready var start = $Start
onready var time = $Time
onready var deaths = $Deaths

func _ready():
	start.text = "From " + loader.get_starting_position()
	time.text = "Time: " + loader.get_elapsed_time()
	deaths.text = "Deaths: " + loader.get_total_deaths()


