extends TextureRect

class_name InventoryGrid

export (Vector2) var tile_pos = Vector2(2,2)
export (Vector2) var grid_limits = Vector2(3,2)

var background : TileMap 
var cell_size : Vector2

var grid_pos : Vector2
var grid_size : Vector2
var grid : Array = []

func _ready():
	init(tile_pos, grid_limits)

func init(tile_pos : Vector2, grid_limits : Vector2):
	background = $BackGround
	cell_size = background.cell_size
	grid_pos = tile_pos
	grid_size = grid_limits
	setup_background_image()
	setup_item_record()
	
func setup_background_image():
	var inner_dimensions := Rect2(grid_pos, grid_size)
	var outer_dimensions := inner_dimensions.grow(1)
	for y in range (outer_dimensions.position.y, outer_dimensions.end.y):
		for x in range (outer_dimensions.position.x, outer_dimensions.end.x):
			background.set_cell(x, y, 0)
	background.update_bitmask_region()
	
func setup_item_record():
	for y in range (grid_size.y):
		grid.append([])
		# warning-ignore:unused_variable
		for x in range (grid_size.x):
			grid[y].append(null)

func get_global_rect() -> Rect2:
	return Rect2(background.global_position + grid_pos * cell_size, grid_size * cell_size)

func insert_item_at_first_available_slot(item : Node2D):
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid[y][x] == null:
				item.global_position = background.global_position + (Vector2(x, y) + grid_pos) * cell_size
				if insert_item(item):
					return true
	return false

func insert_item(item) -> bool:
	var item_pos = item.global_position + cell_size / 2
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	
	if is_grid_space_available(g_pos):
		set_grid_space(g_pos, item)
		item.global_position = background.global_position + grid_pos * cell_size + g_pos * cell_size + cell_size / 2
		return true
	else:
		return false

func pos_to_grid_coord(pos) -> Vector2:
	var local_pos = pos - (background.global_position + grid_pos * cell_size)
	var results = Vector2()
	results.x = int(local_pos.x / cell_size.x)
	results.y = int(local_pos.y / cell_size.y)
	return results

func get_grid_size(item) -> Vector2:
	# Simplified for now
	var results := Vector2(1, 1)
	return results
	
func set_grid_space(pos : Vector2, item : Node2D = null) -> Node2D:
	var old_item = grid[pos.y][pos.x]
	grid[pos.y][pos.x] = item
	return old_item

func is_grid_space_available(pos : Vector2) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x > grid_size.x or pos.y > grid_size.y:
		return false
	if grid[pos.y][pos.x]:
		return false
	return true