extends TileMap

export (Array, int) var hookable_tiles
export (Array, int) var unhookable_pairs

const DEHOOK_RANGE = [-4, -3, -2, -1, 0, 1, 2, 3, 4]

const CORNER_SEARCH_DEPTH = 3

const MAX_CORNER_DISTANCE = 10
const EXTRA_CORNER_POSITION = 1

const TOLERANCE = 0.001

var hook_substitutes = {}
var dehooked_tiles_pos = []

onready var base = get_parent()

func _ready():
	for i in range(len(hookable_tiles)):
		hook_substitutes[hookable_tiles[i]] = unhookable_pairs[i]
		hook_substitutes[unhookable_pairs[i]] = hookable_tiles[i]


func can_stick(collision, pos):
	var tile_pos = world_to_map(to_local(pos))
	tile_pos -= collision.normal
	var tile = get_cellv(tile_pos)
	
	return tile in hookable_tiles


# Given a starting positions (map), recursively adds corner positions to a list
# within a depth. Positions added are in global coordinates
func _rec_get_corner_positions(current_tile_pos, corner_list, tiles_visited, depth):
	if depth >= CORNER_SEARCH_DEPTH:
		return
	
	tiles_visited.append(current_tile_pos)
	
	# Surrounding tiles in order - 0: TOP, 1: DIAG_TOP_RIGHT, 2: RIGHT, 
	# 3: DIAG_BOTTOM_RIGHT, 4: BOTTOM, 5: DIAG_BOTTOM_LEFT, 6: LEFT, 
	# 7: DIAG_TOP_LEFT 
	var vector_list = [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]
	
	# true if the surrounding tile is clear, false otherwise.
	var clear_list = []
	for v in vector_list:
		clear_list.append(get_cellv(current_tile_pos + v) == INVALID_CELL)
	
	var global_pos = map_to_world(current_tile_pos) 
	
	for i in range(8):
		if not clear_list[i] and not current_tile_pos + vector_list[i] in tiles_visited:
			_rec_get_corner_positions(current_tile_pos + vector_list[i], corner_list, tiles_visited, depth + 1)
	
	if get_cellv(current_tile_pos) == INVALID_CELL:
		return
	
	# Top right corner
	if clear_list[0] and clear_list[1] and clear_list[2]:
		corner_list.append(to_global(global_pos + Vector2(1 * cell_size[0], 0) + Vector2(1, -1) * EXTRA_CORNER_POSITION))
	
	# Bottom right corner
	if clear_list[2] and clear_list[3] and clear_list[4]:
		corner_list.append(to_global(global_pos + Vector2(1 * cell_size[0], 1 * cell_size[1]) + Vector2(1, 1) * EXTRA_CORNER_POSITION))
	
	# Bottom left corner
	if clear_list[4] and clear_list[5] and clear_list[6]:
		corner_list.append(to_global(global_pos + Vector2(0, 1 * cell_size[1]) + Vector2(-1, 1) * EXTRA_CORNER_POSITION))
	
	# Top left corner
	if clear_list[6] and clear_list[7] and clear_list[0]:
		corner_list.append(to_global(global_pos + Vector2(-1, -1) * EXTRA_CORNER_POSITION))


func get_corner_positions(pos):
	var tile_pos = world_to_map(to_local(pos))
	
	var corner_positions = []
	
	_rec_get_corner_positions(tile_pos, corner_positions, [], 0)
	
	return corner_positions


func get_nearest_corner(pos):
	var corner_list = get_corner_positions(world_to_map(to_local(pos)))
	
	var closest_position = Vector2(0, 0)
	
	if len(corner_list) > 0:
		closest_position = corner_list[0]
		
		for i in range(1, len(corner_list)):
			if (pos - closest_position).distance_to(Vector2(0, 0)) > (pos - corner_list[i]).distance_to(Vector2(0, 0)):
				closest_position = corner_list[i]
	
	return closest_position


func get_possible_corners(pos, normal):
	var starting_tile = world_to_map(to_local(pos))
	if get_cellv(starting_tile) == INVALID_CELL:
		starting_tile -= normal
	
	var corners = []
	
	var rot_clockwise_vector
	var extra_clockwise_vector
	var extra_counterclockwise_vector
	
	if  normal[1] > TOLERANCE:
		rot_clockwise_vector = Vector2(-1, 0)
		extra_clockwise_vector = Vector2(-1, 1)
		extra_counterclockwise_vector = Vector2(1, 1)
	elif normal[1] < -TOLERANCE:
		rot_clockwise_vector = Vector2(1, 0)
		extra_clockwise_vector = Vector2(1, -1)
		extra_counterclockwise_vector = Vector2(-1, -1)
	elif normal[0] > TOLERANCE:
		rot_clockwise_vector = Vector2(0, 1)
		extra_clockwise_vector = Vector2(1, 1)
		extra_counterclockwise_vector = Vector2(1, -1)
	else:
		rot_clockwise_vector = Vector2(0, -1)
		extra_clockwise_vector = Vector2(-1, -1)
		extra_counterclockwise_vector = Vector2(-1, 1)
	
	for i in range(MAX_CORNER_DISTANCE):
		if get_cellv(starting_tile + (i + 1) * rot_clockwise_vector) == INVALID_CELL:
			corners.append(to_global(map_to_world(starting_tile + i * rot_clockwise_vector) + Vector2(cell_size[0], cell_size[1])/2 + extra_clockwise_vector * (cell_size[0]/2 + EXTRA_CORNER_POSITION)))
			break
	
	for i in range(MAX_CORNER_DISTANCE):
		if get_cellv(starting_tile - (i + 1) * rot_clockwise_vector) == INVALID_CELL:
			corners.append(to_global(map_to_world(starting_tile - i * rot_clockwise_vector) + Vector2(cell_size[0], cell_size[1])/2 + extra_counterclockwise_vector * (cell_size[0]/2 + EXTRA_CORNER_POSITION)))
			break
	
	return corners


func dehook_tiles(collision, pos):
	var tile_pos = world_to_map(to_local(pos))
	tile_pos -= collision.normal
	
	var variance_vector
	
	if  abs(collision.normal[1]) > TOLERANCE:
		variance_vector = Vector2(1, 0)
	else:
		variance_vector = Vector2(0, 1)
	
	var new_tile_pos
	
	for i in DEHOOK_RANGE:
		new_tile_pos = tile_pos + i * variance_vector
		
		var current_tile = get_cellv(new_tile_pos)
		
		if current_tile in hookable_tiles:
			dehooked_tiles_pos.append(new_tile_pos)
			set_cellv(new_tile_pos, hook_substitutes[current_tile])
			update_bitmask_area(new_tile_pos)


func rehook_tiles():
	var pos
	
	for i in range(len(dehooked_tiles_pos)):
		pos = dehooked_tiles_pos.pop_front()
		set_cellv(pos, hook_substitutes[get_cellv(pos)])
		update_bitmask_area(pos)
