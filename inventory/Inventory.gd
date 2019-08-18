extends Control


onready var inv_base = $InventoryBase
onready var grid_backpack : InventoryGrid = $InventoryBase/GridBackPack
var opposite_grid : InventoryGrid

var item_held : Node = null
var item_offset := Vector2()
var last_container = null
var last_pos := Vector2()


func _ready():
	pickup_item("Chicken")
	pickup_item("Chicken")
	pickup_item("Lamp")

func pickup_item(item_id : String):
	var item := ItemDB.get_item(item_id)
	item.z_index = 10
	add_child(item)
	if !grid_backpack.insert_item_at_first_available_slot(item):
		item.queue_free()
		return false
	return true

func set_opposite_inventory_grid(opposite : InventoryGrid):
	opposite_grid = opposite
	