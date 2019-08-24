extends Node

class_name TownGen

const BASE_DEFAULT_TILE_NAME = "Base Grass"
const BASE_WATER_TILE_NAME = "Base Water Auto"
const GROUND_DIRT_TILE_NAME = "Dirt Auto"
const MARKER_TILE_NAME = "marker"
const START_TILE_NAME = "start"
const NOISE_OCTAVES := 3
const NOISE_PERIOD := 20.0
const NOISE_PERSISTENCE := 0.8
const BASE_LAND_THRESHOLD := -0.15
const GROUND_THRESHOLD := 0.0

const BASE_TILEMAP_NAMES := ["Base", "Ground", "Obstacles", "Canopy"]
var map := {}
var SHARED_TILE_SET : TileSet
const SHARED_TILE_SIZE := Vector2(16, 16)
const PORTAL_LAYER_NAME := "Portals"
const INTERACTION_Z_LAYER := 2

var structure_pool := [
	{"x": 1, "y":1, "path": "res://map/structures/Default.tscn", "instance": null},
	{"x": 3, "y":3, "path": "res://map/structures/House_5x5.tscn", "instance": null},
	{"x": 5, "y":5, "path": "res://map/structures/House_3x3.tscn", "instance": null},
]

var portal_table := []

func generate_town(town_seed, town_size : Vector2 = Vector2(64,38)) -> Dictionary:
	
	SHARED_TILE_SET = (load("res://assets/ModerateTileSet.tres") as TileSet)
	load_structure_pool()
	
	var node_2d := Node2D.new()
	create_bare_layers(node_2d)
	
	var rand = RandomNumberGenerator.new()
	rand.seed = town_seed
	
	var noise = setup_noise(rand)
	create_base_layer(noise, node_2d, town_size)
	
	var scene := PackedScene.new()
	assert(scene.pack(node_2d) == OK)
	
	# Pop the scene and the portal table into a return dictionary
	return { "scene" : scene, "portals" : portal_table, "scene_bounds" : Rect2(Vector2(), town_size) }

func load_structure_pool():
	for structure in structure_pool:
		structure["instance"] = load(structure["path"]).instance()

func create_bare_layers(node_2d : Node2D):
	var z := -1
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

func setup_noise(rand : RandomNumberGenerator):
	var noise := { "Base" : OpenSimplexNoise.new(), "Ground" : OpenSimplexNoise.new() }
	
	# Configure noise
	noise["Base"].seed = rand.randi()
	noise["Base"].octaves = NOISE_OCTAVES
	noise["Base"].period = NOISE_PERIOD
	noise["Base"].persistence = NOISE_PERSISTENCE
	
	noise["Ground"].seed = rand.randi()
	noise["Ground"].octaves = NOISE_OCTAVES
	noise["Ground"].period = NOISE_PERIOD
	noise["Ground"].persistence = NOISE_PERSISTENCE
	
	return noise

func create_base_layer(noise : Dictionary, node_2d : Node2D, town_size : Vector2):
	
	var base_default_tile := SHARED_TILE_SET.find_tile_by_name(BASE_DEFAULT_TILE_NAME)
	var base_water_tile   := SHARED_TILE_SET.find_tile_by_name(BASE_WATER_TILE_NAME)
	var ground_dirt_tile  := SHARED_TILE_SET.find_tile_by_name(GROUND_DIRT_TILE_NAME)
	
	# Flood fill the tile map with the water tile to cover the screen size
	for y in range(-1, town_size.y + 1):
		for x in range(-1, town_size.x + 1):
			# Draw islands (using noise)
			if noise["Base"].get_noise_2d(x, y) > BASE_LAND_THRESHOLD:
				map["Base"].set_cell(x, y, base_default_tile)
				
				# Draw some dirt on top of the land, as long as the tile isn't already occupied
				if noise["Ground"].get_noise_2d(x, y) > GROUND_THRESHOLD and map["Ground"].get_cell(x, y) == TileMap.INVALID_CELL:
					map["Ground"].set_cell(x, y, ground_dirt_tile)
			
			else:
				# Default to water
				map["Base"].set_cell(x, y, base_water_tile)
	
	# Find possible positions for structures
	for y in range(-1, town_size.y + 1):
			for x in range(-1, town_size.x + 1):
				if (is_peak_point(x, y, noise["Ground"])):
					attempt_place_obstacle(x, y, noise["Ground"], GROUND_THRESHOLD, node_2d)
	
	# Call autotiling
	for tmap in map.values():
		tmap.update_bitmask_region()

func is_peak_point(x : int, y : int, noise : OpenSimplexNoise) -> bool:
	# If this point is higher than the surrounding points
	var p = noise.get_noise_2d(x, y)
	for ty in range (y-1, y+2):
		for tx in range (x-1, x+2):
			var tp = noise.get_noise_2d(tx, ty)
			if tp > p:
				return false
	return true


func attempt_place_obstacle(x : int, y : int, noise : OpenSimplexNoise, threshold : float, node_2d : Node2D):
	# Find the largest reasonable rect centered on the current 'peak'
	var dx_max = 0
	var dy_max = 0
	var dx_before_dy = true
	var ground_dirt_tile  := SHARED_TILE_SET.find_tile_by_name(GROUND_DIRT_TILE_NAME)
	
	while (dx_max <= 2 and dy_max <= 2
			and noise.get_noise_2d(x + dx_max + 1, y + dy_max + 1) > threshold
			and map["Ground"].get_cell(x + dx_max + 1, y + dy_max + 1) == ground_dirt_tile
			and map["Obstacles"].get_cell(x + dx_max + 1, y + dy_max + 1) == TileMap.INVALID_CELL
			and noise.get_noise_2d(x - dx_max - 1, y + dy_max + 1) > threshold
			and map["Ground"].get_cell(x - dx_max - 1, y + dy_max + 1) == ground_dirt_tile
			and map["Obstacles"].get_cell(x - dx_max - 1, y + dy_max + 1) == TileMap.INVALID_CELL
			and noise.get_noise_2d(x + dx_max + 1, y - dy_max - 1) > threshold
			and map["Ground"].get_cell(x + dx_max + 1, y - dy_max - 1) == ground_dirt_tile
			and map["Obstacles"].get_cell(x + dx_max + 1, y - dy_max - 1) == TileMap.INVALID_CELL
			and noise.get_noise_2d(x - dx_max - 1, y - dy_max - 1) > threshold
			and map["Ground"].get_cell(x - dx_max - 1, y - dy_max - 1) == ground_dirt_tile
			and map["Obstacles"].get_cell(x - dx_max - 1, y - dy_max - 1) == TileMap.INVALID_CELL):
		# Increase in one dimension
		if dx_before_dy:
			dx_max += 1
		else:
			dy_max += 1
		dx_before_dy = not dx_before_dy
	
	## Debug markers
#	var marker_tile := SHARED_TILE_SET.find_tile_by_name(MARKER_TILE_NAME)
#	var start_tile  := SHARED_TILE_SET.find_tile_by_name(START_TILE_NAME)
#	for ty in range (y - dy_max, y + dy_max + 1):
#		for tx in range (x - dx_max, x + dx_max + 1):
#			map["Obstacles"].set_cell(tx, ty, marker_tile)
#	map["Obstacles"].set_cell(x, y, start_tile)
	##
	
	var template_node : Node2D = get_template_that_will_fit(dx_max * 2 + 1, dy_max * 2 + 1)
	var merge_dict : Dictionary = TilemapUtils.merge_structure_into_map(template_node, node_2d, Vector2(x - dx_max, y - dy_max))
	if merge_dict.has("portal_list"):
		portal_table += merge_dict["portal_list"]

func get_template_that_will_fit(width, height) -> Node2D:
	structure_pool.shuffle()
	
	for structure in structure_pool:
		if width >= structure["x"] and height >= structure["y"]:
			return structure["instance"]
	
	# Shouldn't get here
	assert(false)
	return null
