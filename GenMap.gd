extends Node2D

# Config
var base_default_tile_name = "Base Grass"
var base_water_tile_name = "Base Water Auto"
var base_seed = 1

var ground_dirt_tile_name = "Dirt Auto"

var marker_tile_name = "marker"
var start_tile_name = "start"

var noise_octaves := 3
var noise_period := 20.0
var noise_persistence := 0.8

var base_land_threshold := -0.15
var ground_threshold := 0.0

# Reusable references
var base_map          : TileMap
var ground_map        : TileMap
var obstacle_map      : TileMap
var canopy            : TileMap
var structures        : Node2D

var base_tileset      : TileSet
var ground_tileset    : TileSet
var obstacle_tileset  : TileSet # Debug

var base_default_tile : int
var base_water_tile   : int
var ground_dirt_tile  : int
var marker_tile       : int     # Debug
var start_tile        : int     # Debug

var base_noise : OpenSimplexNoise
var ground_noise : OpenSimplexNoise

func _ready():
	setup_reusables()
	create_base_layer()
	
func setup_reusables():
	base_map = $Base
	base_tileset = base_map.tile_set
	ground_map = $Ground
	ground_tileset = ground_map.tile_set
	obstacle_map = $Obstacles
	obstacle_tileset = obstacle_map.tile_set
	canopy = $Canopy
	
	structures = $StructureTemplates
	
	base_default_tile = base_tileset.find_tile_by_name(base_default_tile_name)
	base_water_tile = base_tileset.find_tile_by_name(base_water_tile_name)
	ground_dirt_tile = ground_tileset.find_tile_by_name(ground_dirt_tile_name)
	marker_tile = obstacle_tileset.find_tile_by_name(marker_tile_name)
	start_tile = obstacle_tileset.find_tile_by_name(start_tile_name)
	
	# Configure noise
	base_noise = OpenSimplexNoise.new()
	base_noise.seed = base_seed
	base_noise.octaves = noise_octaves
	base_noise.period = noise_period
	base_noise.persistence = noise_persistence
	
	ground_noise = OpenSimplexNoise.new()
	ground_noise.seed = base_seed + 1
	ground_noise.octaves = noise_octaves
	ground_noise.period = noise_period
	ground_noise.persistence = noise_persistence

func create_base_layer():
	# Flood fill the tile map with the water tile to cover the screen size
	for y in range(-1, (get_viewport().size.y / base_map.cell_size.y) + 1):
		for x in range(-1, (get_viewport().size.x / base_map.cell_size.x) + 1):
			# Draw islands (using noise)
			if base_noise.get_noise_2d(x, y) > base_land_threshold:
				base_map.set_cell(x, y, base_default_tile)
				
				# Draw some dirt on top of the land, as long as the tile isn't occupied
				if ground_noise.get_noise_2d(x, y) > ground_threshold and ground_map.get_cell(x, y) == TileMap.INVALID_CELL:
					ground_map.set_cell(x, y, ground_dirt_tile)
					
					# Find positions for structures
					if (is_peak_point(x, y, ground_noise)):
						attempt_place_obstacle(x, y, ground_noise, ground_threshold)
				
				continue
			# Default to water
			base_map.set_cell(x, y, base_water_tile)

	# Call autotiling
	base_map.update_bitmask_region()
	ground_map.update_bitmask_region()
	
func is_peak_point(x : int, y : int, noise : OpenSimplexNoise) -> bool:
	# If this point is higher than the surrounding points
	var p = noise.get_noise_2d(x, y)
	for ty in range (y-1, y+2):
		for tx in range (x-1, x+2):
			var tp = noise.get_noise_2d(tx, ty)
			if tp > p:
				return false
	return true

func attempt_place_obstacle(x : int, y : int, noise, threshold):
	print ("Plausable structure spot: (" + str(x) + "," + str(y) + ")")
	
	# Find the largest reasonable rect centered on the current 'peak'
	var dx_max = 0
	var dy_max = 0
	var dx_before_dy = true
	
	while (dx_max <= 3 and dy_max <= 3
			and noise.get_noise_2d(x + dx_max + 1, y + dy_max + 1) > threshold
			and obstacle_map.get_cell(x + dx_max + 1, y + dy_max + 1) == TileMap.INVALID_CELL
			and noise.get_noise_2d(x - dx_max - 1, y + dy_max + 1) > threshold
			and obstacle_map.get_cell(x - dx_max - 1, y + dy_max + 1) == TileMap.INVALID_CELL
			and noise.get_noise_2d(x + dx_max + 1, y - dy_max - 1) > threshold
			and obstacle_map.get_cell(x + dx_max + 1, y - dy_max - 1) == TileMap.INVALID_CELL
			and noise.get_noise_2d(x - dx_max - 1, y - dy_max - 1) > threshold
			and obstacle_map.get_cell(x - dx_max - 1, y - dy_max - 1) == TileMap.INVALID_CELL):
		# Increase in one dimension
		if dx_before_dy:
			dx_max += 1
		else:
			dy_max += 1
		dx_before_dy = not dx_before_dy
	
	## Debug markers
	print ("Starting boundary: (" + str(x - dx_max) + "," + str(y - dy_max) + ") to (" + str(x + dx_max) + "," + str(x + dx_max) + ")") 
	for ty in range (y - dy_max, y + dy_max + 1):
		for tx in range (x - dx_max, x + dx_max + 1):
			obstacle_map.set_cell(tx, ty, marker_tile)
	obstacle_map.set_cell(x, y, start_tile)
	##
	
	var template_node : Node2D = get_template_that_will_fit(dx_max * 2 + 1, dy_max * 2 + 1)
	merge_structure_into_map(Vector2(x - dx_max, y - dy_max), template_node)
	
func get_template_that_will_fit(width, height) -> Node2D:
	var template = structures.get_node("Default")
	
	# TODO: Select a structure that will fit - this needs to be smarter
	if width >= 5 and height >= 5:
		template = structures.get_node("Structure01")
	elif width >= 3 and height >= 3:
		template = structures.get_node("Structure03")
	
	return template

func merge_structure_into_map(offset : Vector2, structure : Node2D):
	# For each tilemap in struture, copy it into the similarly name root tilemap
	for sub_node in structure.get_children():
		if sub_node is TileMap:
			# What's the name, and is there one on the root?
			var main_node = get_node(sub_node.name)
			if main_node is TileMap:
				# Copy sub_node into main_node
				var cell_list = (sub_node as TileMap).get_used_cells()
				for cellv in cell_list:
					var tile_id = sub_node.get_cellv(cellv)
					var flip_x = sub_node.is_cell_x_flipped(cellv.x, cellv.y)
					var flip_y = sub_node.is_cell_y_flipped(cellv.x, cellv.y)
					var transpose = sub_node.is_cell_transposed(cellv.x, cellv.y)
					var autov = sub_node.get_cell_autotile_coord(cellv.x, cellv.y)
					var in_pos = cellv + offset
					main_node.set_cell(in_pos.x, in_pos.y, tile_id, flip_x, flip_y, transpose, autov)
