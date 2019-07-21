extends Node2D

# Config
var base_default_tile_name = "Base Grass"
var base_water_tile_name = "Base Water Auto"
var base_land_threshold := -0.15

# Reusable references
var base_map : TileMap
var ground_map : TileMap
var base_tileset : TileSet
var ground_tileset: TileSet
var base_default_tile : int
var base_water_tile : int
var base_noise : OpenSimplexNoise

func _ready():
	setup_reusables()
	create_base_layer()
	
func setup_reusables():
	base_map = $Base
	base_tileset = base_map.tile_set
	ground_map = $Ground
	ground_tileset = ground_map.tile_set
	base_default_tile = base_tileset.find_tile_by_name(base_default_tile_name)
	base_water_tile = base_tileset.find_tile_by_name(base_water_tile_name)
	
	# Configure noise
	base_noise = OpenSimplexNoise.new()
	base_noise.seed = 1
	base_noise.octaves = 3
	base_noise.period = 20.0
	base_noise.persistence = 0.8

func create_base_layer():
	# Flood fill the tile map with the water tile to cover the screen size
	for y in range(-1, (get_viewport().size.y / base_map.cell_size.y) + 1):
		for x in range(-1, (get_viewport().size.x / base_map.cell_size.x) + 1):
			# Draw islands (using noise)
			if base_noise.get_noise_2d(x, y) > base_land_threshold:
				base_map.set_cell(x, y, base_default_tile)
				continue
			# Default to water
			base_map.set_cell(x, y, base_water_tile)
	
	# Call autotiling
	base_map.update_bitmask_region()