extends Node2D

class_name Player

export(float) var speed = 4.0

var anim_sp_ratio = 0.5
var axis_flip = false # This is to make diagonal movement 'slightly' less tedious
var bounds : Rect2 = Rect2()
var facing : Vector2 = Vector2()

# warning-ignore:unused_class_variable
onready var body : KinematicBody2D = $KinematicBody2D
onready var rays : Dictionary = {
		"0_1": $RayCastDown,
		"0_-1": $RayCastUp,
		"-1_0": $RayCastLeft,
		"1_0": $RayCastRight,
	}
onready var frozen : bool = true
onready var anim := $AnimationPlayer
onready var inv := $Inventory

func _enter_tree():
	print("Player _enter_tree")
	set_process(true)

func _ready():
	print("Player _ready")
	anim.playback_speed = speed * anim_sp_ratio
	inv.set_visiblity(false)

# warning-ignore:unused_argument
func _process(delta):
	var dir : Vector2 = get_input_dir()
	if dir != Vector2.ZERO:
		var anim_name : String = str(int(dir.x)) + "_" + str(int(dir.y))
		if can_move(anim_name):
			var target : Vector2 = position + dir * TilemapUtils.SHARED_TILE_SIZE
			$Tween.interpolate_property(self, "position", position, target, 1.0 / speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		else:
			# If we're walking into an item, give it a bump
			var collision_item = get_collider_item(anim_name)
			if collision_item and collision_item.has_method("bump"):
				collision_item.bump(dir)
			print (str(collision_item))
			
			# Play the "look" only animation
			anim_name += "_look"
			
		anim.play(anim_name)
		facing = dir
	
	# Are we trying to "use" something?
	if Input.is_action_just_pressed("ui_select"):
		var facing_name : String = str(int(facing.x)) + "_" + str(int(facing.y))
		var collision_item = get_collider_item(facing_name)
		if collision_item:
			collision_item.use(facing, self)
	
	if Input.is_action_just_pressed("inv_show"):
		if inv.is_visible() == false:
			print("Show Inventory")
			show_inventory()
		else:
			print("Hide Inventory")
			hide_inventory()

func can_move(anim_name : String):
	var ray : RayCast2D = rays[anim_name]
	if ray.is_colliding():
		return false
	if frozen:
		return false
	if anim_name == "-1_0" and position.x - (1 * TilemapUtils.SHARED_TILE_SIZE.x) < bounds.position.x:
		return false
	if anim_name == "0_-1" and position.y - (1 * TilemapUtils.SHARED_TILE_SIZE.y) < bounds.position.y:
		return false
	if anim_name == "1_0" and position.x + (1 * TilemapUtils.SHARED_TILE_SIZE.x) >= bounds.end.x:
		return false
	if anim_name == "0_1" and position.y + (1 * TilemapUtils.SHARED_TILE_SIZE.y) >= bounds.end.y:
		return false
		
	return true

func get_collider_item(anim_name : String) -> Object:
	# Return an Item if it's an item that can be used
	var obj = null
	var ray : RayCast2D = rays[anim_name]
	if ray.is_colliding():
		var collider = ray.get_collider()
		if not collider is TileMap:
			var parent = collider.get_parent()
			if parent.has_method("use"):
				obj = parent
	return obj

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Tween_tween_started(object, key):
	set_process(false)
 
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Tween_tween_completed(object, key):
	set_process(true)
	
func freeze():
	frozen = true

func thaw():
	frozen = false

func get_input_dir() -> Vector2:
	var dir = Vector2()
	if not axis_flip:
		dir.y = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
	if dir.y == 0:
		dir.x = (int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")))
	if axis_flip and dir.x == 0:
		dir.y = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
		
	if dir != Vector2.ZERO:
		axis_flip = not axis_flip
 
	return dir

func has_collided() -> bool:
	return true if body.get_collider() else false

func set_view_tile_bounds(tile_bounds : Rect2):
	bounds.position = (tile_bounds.position * TilemapUtils.SHARED_TILE_SIZE) - (TilemapUtils.SHARED_TILE_SIZE / 2)
	bounds.end = (tile_bounds.end * TilemapUtils.SHARED_TILE_SIZE) + TilemapUtils.SHARED_TILE_SIZE
	$Camera2D.limit_left   = bounds.position.x
	$Camera2D.limit_right  = bounds.end.x
	$Camera2D.limit_top    = bounds.position.y
	$Camera2D.limit_bottom = bounds.end.y

func show_opposite_inventory_grid(inv_grid : InventoryGrid):
	print("Setting opposite inventory " + str(inv_grid))
	# Add the opposite inventory_grid to the inventory display and show the inventory
	inv.set_opposite_inventory_grid(inv_grid)
	show_inventory()

func show_inventory():
	freeze()
	inv.set_visiblity(true)

func hide_inventory():
	inv.set_visiblity(false)
	inv.set_opposite_inventory_grid(null)
	thaw()