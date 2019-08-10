extends Node

const WALL_TILE_NAME := "Wall Top Auto"
const FLOOR_TILE_NAME := "Underfloor Atlas"
const BACK_WALL_TILE_NAME := "Brick"

const BASE_TILEMAP_NAMES := ["Base", "Obstacles", "Canopy"]
var map := {}
var SHARED_TILE_SIZE := Vector2(16,16)
var SHARED_TILE_SET : TileSet
const INTERACTION_Z_LAYER := 1

var return_portal : Node2D

func generate(room_seed, room_size : Vector2 = Vector2(19, 12)) -> Dictionary:
	
	SHARED_TILE_SET = (load("res://assets/ModerateTileSet.tres") as TileSet)
	
	var node_2d := Node2D.new()
	create_bare_layers(node_2d)
	
	# TODO: Generate the interior of a small building
	create_base_layers(room_seed, node_2d, room_size)
	
	# Call autotiling
	for tmap in map.values():
		tmap.update_bitmask_region()
	
	var scene := PackedScene.new()
	assert(scene.pack(node_2d) == OK)
	
	print ("Room generated: " + str(scene) + ", exit: " + str(return_portal))
	
	return { "scene" : scene, "return_portal" : return_portal, "scene_bounds" : Rect2(Vector2(), room_size) }

func create_bare_layers(node_2d : Node2D):
	var z := 0
	for layer in BASE_TILEMAP_NAMES:
		var tilemap := TileMap.new()
		tilemap.set_name(layer)
		tilemap.cell_size = SHARED_TILE_SIZE
		tilemap.tile_set = SHARED_TILE_SET
		tilemap.format = 1 # Appears to be important for loading the tilemap from a PackedScene
		tilemap.z_index = z
		z += 1
		node_2d.add_child(tilemap, true)
		tilemap.owner = node_2d
		map[layer] = tilemap

func create_base_layers(rseed : int, node_2d : Node2D, room_size : Vector2):
	
	var wall_tile := SHARED_TILE_SET.find_tile_by_name(WALL_TILE_NAME)
	var floor_tile := SHARED_TILE_SET.find_tile_by_name(FLOOR_TILE_NAME)
	var back_wall_tile := SHARED_TILE_SET.find_tile_by_name(BACK_WALL_TILE_NAME)
	
	for y in range(0, room_size.y + 1):
		for x in range(0, room_size.x + 1):
			if y == 0 or x == 0 or y == (room_size.y) or x == (room_size.x):
				map["Obstacles"].set_cell(x, y, wall_tile)
			elif y == 1:
				map["Obstacles"].set_cell(x, y, back_wall_tile)
			map["Base"].set_cell(x, y, floor_tile)
	
	var mid_x : int = int(room_size.x) / 2
	var y : int = room_size.y
	map["Obstacles"].set_cell(mid_x, y, TileMap.INVALID_CELL)
		
	# Put the return portal at the relevant location
	return_portal = load("res://town/structures/House_3x3/Internal_Door.tscn").instance() as Node2D
	return_portal.set_name("To_Outside")
	return_portal.z_index = INTERACTION_Z_LAYER
	return_portal.init_position(Vector2(mid_x, y) * SHARED_TILE_SIZE)
	return_portal.init_scene(node_2d)
	node_2d.add_child(return_portal, true)
	return_portal.owner = node_2d
	
	