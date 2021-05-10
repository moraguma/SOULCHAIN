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

# SCREENSHAKE VARIABLES
var trauma = 0.0

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
