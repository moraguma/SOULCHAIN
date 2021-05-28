extends Sprite

enum DIRECTION {up, diagonal_up_right, right, diagonal_down_right, down, diagonal_down_left, left, diagonal_up_left}
export (DIRECTION) var direction = DIRECTION.right


func _ready():
	match direction:
		DIRECTION.right:
			frame = 0
		DIRECTION.diagonal_down_right:
			frame = 1
		DIRECTION.down:
			frame = 2
		DIRECTION.diagonal_down_left:
			frame = 3
		DIRECTION.left:
			frame = 4
		DIRECTION.diagonal_up_left:
			frame = 5
		DIRECTION.up:
			frame = 6
		DIRECTION.diagonal_up_right:
			frame = 7
