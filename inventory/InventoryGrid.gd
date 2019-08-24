extends Control

class_name InventoryGrid

const INV_TILE_NAME := "Inventory_Grid"
var INV_TILE : int

export (Vector2) var tile_pos = Vector2(-10,-10)  # Default to off screen
export (Vector2) var grid_limits = Vector2(1,1)

var background : TileMap 
var cell_size : Vector2

var grid_bounds : Rect2
var grid : Array = []

func _ready():
	init(tile_pos, grid_limits)
	
func add_item(item_id : String):
	var item : BaseItem = ItemDB.get_item(item_id)
	if !insert_item_at_first_available_slot(item):
		item.queue_free()
		return false
	return true

func init(tile_pos : Vector2, grid_limits : Vector2):
	# Get tiled inventory related info
	background = $BackGround
	cell_size = background.cell_size
	INV_TILE = background.tile_set.find_tile_by_name(INV_TILE_NAME)
	# Setup the storage and the backing grid display
	grid_bounds = Rect2(tile_pos, Vector2())
	setup_item_record(grid_limits)

func setup_item_record(size : Vector2):
	var new_grid := []
	for y in range (size.y):
		new_grid.append([])
		# warning-ignore:unused_variable
		for x in range (size.x):
			new_grid[y].append(null)
	set_item_grid(new_grid)

func set_item_grid(item_grid : Array):
	print ("Setting item grid " + str(item_grid) + " on " + str(self))
	grid = item_grid
	var gb_size = Vector2()
	gb_size.y = grid.size()
	if not grid.empty():
		gb_size.x = grid[0].size()
	grid_bounds.size = gb_size
	print ("Bounds changed to " + str(grid_bounds))

	setup_background_image()
	update_item_properties()

func get_item_grid() -> Array:
	return grid

func setup_background_image():
	background.clear()
	var outer_dimensions := grid_bounds.grow(1)
	print ("Setting tiles in area " + str(outer_dimensions))
	var debug = ""
	for y in range (outer_dimensions.position.y, outer_dimensions.end.y):
		for x in range (outer_dimensions.position.x, outer_dimensions.end.x):
			var c_pos = Vector2(x, y)
			background.set_cellv(c_pos, INV_TILE)
			debug += str(c_pos)
	print (debug)
	background.update_bitmask_region()

func update_item_properties():
	for y in range(grid_bounds.size.y):
		for x in range(grid_bounds.size.x):
			if is_instance_valid(grid[y][x]):
				var item : BaseItem = grid[y][x]
				var g_pos := Vector2(x, y)
				print ("Update item " + str(item) + " at " + str(g_pos))
				update_item_to_cell_pos(item, Vector2(x, y))

func has_point(point):
	return get_global_rect().has_point(point)

func get_global_rect() -> Rect2:
	return Rect2(grid_bounds.position * cell_size, grid_bounds.size * cell_size)

func insert_item_at_first_available_slot(item : BaseItem):
	print ("Attempting to insert at first location: " + str(item))
	for y in range(grid_bounds.size.y):
		for x in range(grid_bounds.size.x):
			if not is_instance_valid(grid[y][x]):
				print("Empty location - x:" + str(x) + ", y:" + str(y))
				var g_pos = Vector2(x, y)
				if insert_item(item, g_pos):
					return true
	return false

func insert_item(item : BaseItem, g_pos = null) -> bool:
	if not is_a_parent_of(item):
		var parent = item.get_parent()
		if parent:
			parent.remove_child(item)
		add_child(item)
	if g_pos == null:
		var item_pos = item.get_global_rect().position
		g_pos = pos_to_grid_coord(item_pos)
	
	print("Trying to insert " + str(item) + " on " + str(self) + " at " + str(g_pos))
	
	if g_pos != null and is_grid_space_available(g_pos):
		set_grid_space(g_pos, item)
		print("background.global_position: " + str(background.global_position))
		print("g_pos: " + str(g_pos))
		update_item_to_cell_pos(item, g_pos)
		print("Item rect: " + str(item.get_global_rect()))
		return true
	else:
		return false

func update_item_to_cell_pos(item : BaseItem, g_pos : Vector2):
	item.rect_position = (grid_bounds.position + g_pos) * cell_size + (cell_size - item.rect_size) / 2

func pos_to_grid_coord(pos : Vector2):
	var local_pos = pos - (grid_bounds.position * cell_size)
	var grid_b = Rect2(Vector2(), grid_bounds.size)
	var results = Vector2()
	print ("local_pos " + str(local_pos) + ", grid_b " + str(grid_b))
	results.x = int(local_pos.x / cell_size.x)
	results.y = int(local_pos.y / cell_size.y)
	print ("Got cell " + str(results) + " from pos " + str(pos))
	if not grid_b.has_point(results):
		return null
	return results

func set_grid_space(pos : Vector2, item = null):
	grid[pos.y][pos.x] = item

func is_grid_space_available(pos : Vector2) -> bool:
	var grid_b = Rect2(Vector2(), grid_bounds.size)
	print ("Checking if grid space " + str(grid_b) + " is free for pos " + str(pos))
	if not grid_b.has_point(pos):
		return false
	if is_instance_valid(grid[pos.y][pos.x]):
		return false
	return true

func grab_item(pos : Vector2) -> BaseItem:
	var ind : Vector2 = pos_to_grid_coord(pos)
	if ind == null:
		return null
		
	var item : BaseItem = grid[ind.y][ind.x]
	set_grid_space(ind, null)
	print("Grabbing  " + str(item) + " from " + str(self) + " at " + str(ind))
	return item

func _on_InventoryGrid_visibility_changed():
	# Changing visibility on this tecture rect doesn't apply to sub scenes
	for row in grid:
		for inv_item in row:
			if inv_item:
				inv_item.visible = self.visible
