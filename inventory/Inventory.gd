extends CanvasLayer

onready var control = $Control
onready var grid_backpack : InventoryGrid = $Control/Viewport/GridBackPack
onready var opposite_grid : InventoryGrid = $Control/Viewport/OppositeGrid

var item_held : BaseItem = null
var item_offset := Vector2()
var last_container = null
var last_pos := Vector2()

var opposite_source

func _ready():
	pickup_item("Chicken")
	pickup_item("Chicken")
	pickup_item("Lamp")

func pickup_item(item_id : String):
	return grid_backpack.add_item(item_id)

# warning-ignore:unused_argument
func _process(delta):
	var cursor_pos = control.get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		grab(cursor_pos)
	if Input.is_action_just_released("inv_grab"):
		release(cursor_pos)
	if is_instance_valid(item_held):
		item_held.rect_global_position = cursor_pos + item_offset

func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if is_instance_valid(c) and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if is_instance_valid(item_held):
			item_held.set_as_toplevel(true)
			last_container = c
			last_pos = item_held.rect_global_position
			item_offset = item_held.rect_global_position - cursor_pos
#			c.move_child(item_held, get_child_count())
	print("Grabbed " + str(item_held) + " from " + str(c))

func release(cursor_pos):
	if not is_instance_valid(item_held):
		return
	print ("Releasing grip of " + str(item_held) + " at " + str(cursor_pos))
	var c = get_container_under_cursor(cursor_pos)
	print ("Attempt to insert into contrainer " + str(c))
	if not is_instance_valid(c):
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held.set_as_toplevel(false)
			item_held = null
		else:
			return_item()
	else:
		return_item()

func get_container_under_cursor(cursor_pos):
	if grid_backpack.has_point(cursor_pos):
		return grid_backpack
	if is_instance_valid(opposite_source):
		if opposite_grid.has_point(cursor_pos):
			return opposite_grid
	return null

func drop_item():
	print("Dropping (Deleting) item " + str(item_held))
	# TODO: Create an in-world object to represent this inv item
	item_held.queue_free()
	item_held = null

func return_item():
	print("Returning item to " + str(last_pos) + " on " + str(last_container))
	item_held.rect_global_position = last_pos
	last_container.insert_item(item_held)
	item_held.set_as_toplevel(false)
	item_held = null

func set_opposite_inventory_grid_data(source):
	print("Getting opposite inventory grid: " + str(source))
	return_opposite_grid_data()

	opposite_source = source
	if is_instance_valid(opposite_source) and opposite_source.has_method("get_item_store"):
		print(" opposite_source " + str(opposite_source) + " exists and has a get_item_store method")
		var store : Array = opposite_source.get_item_store()
		print("set the grid array " + str(opposite_grid) + " with store " + str(store))
		opposite_grid.set_item_grid(store)

func return_opposite_grid_data():
	# Return any inventory we've previously copied
	if is_instance_valid(opposite_source) and opposite_source.has_method("set_item_store"):
		opposite_source.set_item_store(opposite_grid.get_item_grid())
		opposite_source = null

func set_visiblity(visible : bool):
	control.visible = visible

func is_visible() -> bool:
	return control.visible

func _on_Control_visibility_changed():
	if control.visible == false:
		return_opposite_grid_data()
	# Oddly, just changing visiblity on control doesn't change it on the sub scene
	grid_backpack.visible = control.visible
	opposite_grid.visible = false
	if is_instance_valid(opposite_source):
		opposite_grid.visible = control.visible
