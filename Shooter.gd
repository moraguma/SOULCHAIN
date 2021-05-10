extends Area2D

enum DIRECTION {up, diagonal_up_right, right, diagonal_down_right, down, diagonal_down_left, left, diagonal_up_left}
export (DIRECTION) var direction = DIRECTION.right

var dir = Vector2(0, 0)
var idle_anim = "idle_up"

onready var animation_player = $AnimationPlayer

onready var shoot_sound = $ShootSound

# Called when the node enters the scene tree for the first time.
func _ready():
	match direction:
		DIRECTION.up:
			dir = Vector2(0, -1)
			idle_anim = "idle_up"
		DIRECTION.diagonal_up_right:
			dir = Vector2(1, -1)
			idle_anim = "idle_diagonal_up_right"
		DIRECTION.right:
			dir = Vector2(1, 0)
			idle_anim = "idle_right"
		DIRECTION.diagonal_down_right:
			dir = Vector2(1, 1)
			idle_anim = "idle_diagonal_down_right"
		DIRECTION.down:
			dir = Vector2(0, 1)
			idle_anim = "idle_down"
		DIRECTION.diagonal_down_left:
			dir = Vector2(-1, 1)
			idle_anim = "idle_diagonal_down_left"
		DIRECTION.left:
			dir = Vector2(-1, 0)
			idle_anim = "idle_left"
		DIRECTION.diagonal_up_left:
			dir = Vector2(-1, -1)
			idle_anim = "idle_diagonal_up_left"


func _physics_process(delta):
	if animation_player.current_animation != "shoot":
		animation_player.play(idle_anim)


func force_idle():
	animation_player.play(idle_anim)


func shoot(body):
	shoot_sound.play()
	
	animation_player.play("shoot")
	
	body.get_shot(dir, position)
