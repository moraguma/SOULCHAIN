tool
extends TileSet

const GREEN_ASH = 0
const RED_ASH = 1
const BRICK = 2
const RED_BRICK = 3

var binds = {
	BRICK: [RED_BRICK],
	RED_BRICK: [BRICK]
}

func _is_tile_bound(id, nid):
	return nid in binds[id]
