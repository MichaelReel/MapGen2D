extends CanvasLayer

onready var control = $Control
onready var grid_backpack : InventoryGrid = $Control/Viewport/GridBackPack
var opposite_grid : InventoryGrid

var item_held : BaseItem = null
var item_offset := Vector2()
var last_container = null
var last_pos := Vector2()


func _ready():
	pickup_item("Chicken")
	pickup_item("Chicken")
	pickup_item("Lamp")

func pickup_item(item_id : String):
	var item := ItemDB.get_item(item_id)
	add_child(item)
	item.set_z_index(11)
	if !grid_backpack.insert_item_at_first_available_slot(item):
		item.queue_free()
		return false
	return true

func _process(delta):
	var cursor_pos = control.get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		grab(cursor_pos)
	if Input.is_action_just_released("inv_grab"):
		release(cursor_pos)
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_offset

func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			last_pos = item_held.rect_global_position
			item_offset = item_held.rect_global_position - cursor_pos
			move_child(item_held, get_child_count())

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()

func get_container_under_cursor(cursor_pos):
	if grid_backpack.get_global_rect().has_point(cursor_pos):
		return grid_backpack
	elif opposite_grid != null and opposite_grid.get_global_rect().has_point(cursor_pos):
		return opposite_grid
	return null

func drop_item():
	item_held.queue_free()
	item_held = null

func return_item():
	item_held.rect_global_position = last_pos
	last_container.insert_item(item_held)
	item_held = null

func set_opposite_inventory_grid(opposite : InventoryGrid):
	opposite_grid = opposite

func set_visiblity(visible : bool):
	control.visible = visible

func is_visible() -> bool:
	return control.visible

func _on_Control_visibility_changed():
	# Oddly, just changing visiblity on control doesn't change it on the sub scene
	grid_backpack.visible = control.visible
