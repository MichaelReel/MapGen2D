extends Node

const WALL_TILE_NAME := "Wall Top Auto"
const FLOOR_TILE_NAME := "Underfloor Atlas"
const BACK_WALL_TILE_NAME := "Brick"

const BASE_TILEMAP_NAMES := ["Base", "Obstacles", "Canopy"]
var map := {}

var return_portal : Node2D

var kitchen_pool := [
	{"path": "res://map/structures/House_5x5/rooms/Kitchen_01.tscn", "instance": null},
]

var bedroom_pool := [
	{"path": "res://map/structures/House_5x5/rooms/Bedroom_01.tscn", "instance": null},
]

func generate(room_seed, room_size : Vector2 = Vector2(16, 9)) -> Dictionary:
	var rand = RandomNumberGenerator.new()
	rand.seed = room_seed
	
	load_room_pools()
	
	var node_2d := Node2D.new()
	create_bare_layers(node_2d)
	
	# Generate the interior of a medium building
	create_base_layers(room_seed, node_2d, room_size)
	
	# Call autotiling
	for tmap in map.values():
		tmap.update_bitmask_region()
	
	var scene := PackedScene.new()
	assert(scene.pack(node_2d) == OK)
	
	return { "scene" : scene, "return_portal" : return_portal, "scene_bounds" : Rect2(Vector2(), room_size - Vector2(1,1)) }

func load_room_pools():
	for room in kitchen_pool:
		room["instance"] = load(room["path"]).instance()
	for room in bedroom_pool:
		room["instance"] = load(room["path"]).instance()

func create_bare_layers(node_2d : Node2D):
	var z := 0
	for layer in BASE_TILEMAP_NAMES:
		var tilemap := TileMap.new()
		tilemap.set_name(layer)
		tilemap.cell_size = TilemapUtils.SHARED_TILE_SIZE
		tilemap.tile_set = TilemapUtils.SHARED_TILE_SET
		tilemap.format = 1 # Appears to be important for loading the tilemap from a PackedScene
		tilemap.z_index = z
		z += 1
		node_2d.add_child(tilemap, true)
		tilemap.owner = node_2d
		map[layer] = tilemap

func create_base_layers(rseed : int, node_2d : Node2D, room_size : Vector2):
	
	var rand = RandomNumberGenerator.new()
	rand.seed = rseed
	
	var wall_tile := TilemapUtils.SHARED_TILE_SET.find_tile_by_name(WALL_TILE_NAME)
	var floor_tile := TilemapUtils.SHARED_TILE_SET.find_tile_by_name(FLOOR_TILE_NAME)
	var back_wall_tile := TilemapUtils.SHARED_TILE_SET.find_tile_by_name(BACK_WALL_TILE_NAME)
	
	for y in range(0, room_size.y):
		for x in range(0, room_size.x):
			if y == 0 or x == 0 or y == (room_size.y - 1) or x == (room_size.x - 1):
				map["Obstacles"].set_cell(x, y, wall_tile)
			elif y == 1:
				map["Obstacles"].set_cell(x, y, back_wall_tile)
			map["Base"].set_cell(x, y, floor_tile)
	
	# Get a kitchen layout and bedroom layout and merge them into the room
	var kitchen : Node2D = kitchen_pool[randi() % kitchen_pool.size()]["instance"]
	var bedroom : Node2D = bedroom_pool[randi() % bedroom_pool.size()]["instance"]
	
	var kitchen_left : bool = true if rand.randi() % 2 == 1 else false
	var kitchen_offset = Vector2(1,2)
	var bedroom_offset = Vector2(1,2)
	if kitchen_left:
		bedroom_offset = Vector2(9,2)
	else:
		kitchen_offset = Vector2(9,2)
	# warning-ignore:return_value_discarded
	TilemapUtils.merge_structure_into_map(kitchen, node_2d, kitchen_offset)
	# warning-ignore:return_value_discarded
	TilemapUtils.merge_structure_into_map(bedroom, node_2d, bedroom_offset)
	
	var mid_x := 8
	# warning-ignore:narrowing_conversion
	var y : int = room_size.y - 1
	map["Obstacles"].set_cell(mid_x, y, TileMap.INVALID_CELL)
		
	# Put the return portal at the relevant location
	return_portal = load("res://items/Door.tscn").instance() as Node2D
	return_portal.set_name("To_Outside")
	return_portal.z_index = TilemapUtils.INTERACTION_Z_LAYER
	return_portal.init_position(Vector2(mid_x, y) * TilemapUtils.SHARED_TILE_SIZE)
	return_portal.init_scene(node_2d)
	node_2d.add_child(return_portal, true)
	return_portal.owner = node_2d
	
	