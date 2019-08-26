extends Node2D

class_name ItemContainer

export (Vector2) var storage_size = Vector2(2,2)
onready var anim = $AnimationPlayer
var grid : Array

func _get_property_list():
	# This tells the engine to save our 2D 'grid' of items
	return [
		{ "name" : "grid", "type" : TYPE_ARRAY }
	]

func _ready():
	if grid.empty():
		create_storage(storage_size)
		add_item("Chicken")

func create_storage(size : Vector2):
	var new_grid := []
	for y in range (size.y):
		new_grid.append([])
		# warning-ignore:unused_variable
		for x in range (size.x):
			new_grid[y].append(null)
	set_item_store(new_grid)

func use(dir : Vector2, user : Node):
	anim.play("open")
	
	# Show an inventory transfer screen
	if user and user.has_method("show_opposite_inventory_grid"):
		user.show_opposite_inventory_grid(self)

func bump(dir : Vector2):
	var dir_name : String = str(int(dir.x)) + "_" + str(int(dir.y))
	anim.play("bump_" + dir_name)

func set_item_store(i_grid : Array):
	grid = i_grid
	
func get_item_store() -> Array:
	return grid

func add_item(item_id : String):
	var item : BaseItem = ItemDB.get_item(item_id)
	if !insert_item_at_first_available_slot(item):
		item.queue_free()
		return false
	return true

func insert_item_at_first_available_slot(item : BaseItem):
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if not is_instance_valid(grid[y][x]):
				grid[y][x] = item
				return true
	return false