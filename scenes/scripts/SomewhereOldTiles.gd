extends "res://scenes/scripts/supers/TilemapTiles.gd"

const ROCK = 0
const GREEN_ROCK = 1
const ORANGE_ROCK = 2
const BRICK = 3
const GREEN_BRICK = 4
const ORANGE_BRICK = 5

func _ready():
	hookable_tiles = [GREEN_ROCK, GREEN_BRICK]
	hook_substitutes = {GREEN_ROCK: ORANGE_ROCK, GREEN_BRICK: ORANGE_BRICK, 
						ORANGE_ROCK: GREEN_ROCK, ORANGE_BRICK: GREEN_BRICK}
