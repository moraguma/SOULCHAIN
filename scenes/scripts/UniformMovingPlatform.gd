extends KinematicBody2D

const TRANSFER_ACCELERATION = 0.1

var last_known_position = Vector2(0, 0)
var transfer_velocity = Vector2(0, 0)
var velocity = Vector2(0, 0)


onready var animation_player = $AnimationPlayer
onready var tiles = $Tiles


func _ready():
	if animation_player.has_animation("move_loop"):
		animation_player.play("move_loop")
		
		last_known_position = position


func _physics_process(delta):
	velocity = (position - last_known_position) / delta
	last_known_position = position
	transfer_velocity = transfer_velocity.linear_interpolate(velocity, TRANSFER_ACCELERATION)


func get_associated_tilemap():
	return tiles


func get_transfer_velocity():
	if transfer_velocity.distance_to(Vector2(0, 0)) > velocity.distance_to(Vector2(0, 0)):
		return transfer_velocity
	return velocity
