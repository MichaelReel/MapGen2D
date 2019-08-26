extends Node2D

class_name ItemContainer

export (Vector2) var storage_size = Vector2(2,2)
onready var anim = $AnimationPlayer
var grid : Array

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
	print ("use on " + str(self) + ", dir: " + str(dir) + " by " + str(user))
	anim.play("open")
	
	# Show an inventory transfer screen
	if user and user.has_method("show_opposite_inventory_grid"):
		print ("calling show_opposite_inventory_grid on " + str(user))
		user.show_opposite_inventory_grid(self)

func bump(dir : Vector2):
	print ("bump on " + str(self) + ", dir: " + str(dir))
	var dir_name : String = str(int(dir.x)) + "_" + str(int(dir.y))
	anim.play("bump_" + dir_name)

func set_item_store(i_grid : Array):
	print ("Setting store " + str(i_grid) + " on container " + str(self))
	grid = i_grid
	print ("Store set " + str(grid) + " on container " + str(self))
	
func get_item_store() -> Array:
	print ("Getting store " + str(grid) + " from container " + str(self))
	return grid

func add_item(item_id : String):
	var item : BaseItem = ItemDB.get_item(item_id)
	if !insert_item_at_first_available_slot(item):
		item.queue_free()
		return false
	print("Chest contents updated: " + str(grid))
	return true

func insert_item_at_first_available_slot(item : BaseItem):
	print ("Attempting to insert in to container at first location: " + str(item))
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if not is_instance_valid(grid[y][x]):
				print("Empty location - x:" + str(x) + ", y:" + str(y))
				grid[y][x] = item
				return true
	return false