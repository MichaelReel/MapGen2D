extends Node2D

onready var anim = $AnimationPlayer
var contents : InventoryGrid

func _ready():
	print("AnimationPlayer ready: " + str(anim))
	contents = $InventoryGrid
	contents.visible = false

func use(dir : Vector2, user : Node):
	print ("use on " + str(self) + ", dir: " + str(dir))
	anim.play("open")
	
	# Show an inventory transfer screen
	if user.has_method("show_opposite_inventory_grid"):
		user.show_opposite_inventory_grid(contents)
	# TODO: Need to implement some kind of inventory on both the player and objects

func bump(dir : Vector2):
	print ("bump on " + str(self) + ", dir: " + str(dir))
	var dir_name : String = str(int(dir.x)) + "_" + str(int(dir.y))
	anim.play("bump_" + dir_name)
