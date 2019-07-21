extends Node2D

# Config
var base_default_tile_name = "Base Grass"
var base_water_tile_name = "Base Water Auto"
var base_seed = 1

var ground_dirt_tile_name = "Dirt Auto"

var noise_octaves := 3
var noise_period := 20.0
var noise_persistence := 0.8

var base_land_threshold := -0.15
var ground_threshold := 0.0

# Reusable references
var base_map : TileMap
var ground_map : TileMap
var base_tileset : TileSet
var ground_tileset: TileSet
var base_default_tile : int
var base_water_tile : int
var ground_dirt_tile : int

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
	base_default_tile = base_tileset.find_tile_by_name(base_default_tile_name)
	base_water_tile = base_tileset.find_tile_by_name(base_water_tile_name)
	ground_dirt_tile = ground_tileset.find_tile_by_name(ground_dirt_tile_name)
	
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
				
				# Draw some dirt on top of the land
				if ground_noise.get_noise_2d(x, y) > ground_threshold:
					ground_map.set_cell(x, y, ground_dirt_tile)
				
				continue
			# Default to water
			base_map.set_cell(x, y, base_water_tile)

	# Call autotiling
	base_map.update_bitmask_region()
	ground_map.update_bitmask_region()