extends Node

const INTERACTION_Z_LAYER := 1
const SHARED_TILE_SIZE := Vector2(16, 16)
onready var SHARED_TILE_SET = (load("res://assets/ModerateTileSet.tres") as TileSet)

func merge_structure_into_map(structure : Node2D, map : Node2D, offset : Vector2 = Vector2()) -> Dictionary:
	# Setup return table for specially placed elements
	var return_dict : Dictionary = {}
	# For each tilemap in struture, copy it into the similarly name root tilemap
	for sub_node in structure.get_children():
		if sub_node is TileMap:
			# What's the name, and is there one on the root?
			var main_node = map.get_node(sub_node.name)
			if main_node is TileMap:
				# Copy sub_node into main_node
				var cell_list = (sub_node as TileMap).get_used_cells()
				for cellv in cell_list:
					var tile_id : int = sub_node.get_cellv(cellv)
					var flip_x : bool = sub_node.is_cell_x_flipped(cellv.x, cellv.y)
					var flip_y : bool = sub_node.is_cell_y_flipped(cellv.x, cellv.y)
					var transpose : bool = sub_node.is_cell_transposed(cellv.x, cellv.y)
					var autov : Vector2 = sub_node.get_cell_autotile_coord(cellv.x, cellv.y)
					var in_pos : Vector2 = cellv + offset
					main_node.set_cell(in_pos.x, in_pos.y, tile_id, flip_x, flip_y, transpose, autov)
		elif sub_node.has_method("get_portal"):
			# Setup return storage for portals
			if not return_dict.has("portal_list"):
				return_dict["portal_list"] = []
			
			# Get portal with generation hint
			var portal = sub_node.get_portal(offset * SHARED_TILE_SIZE)
			portal["sprite"].init_scene(map) 
			return_dict["portal_list"].append(portal)
			
			# Add the portal scene to the world
			portal["sprite"].z_index = INTERACTION_Z_LAYER
			map.add_child(portal["sprite"])
			portal["sprite"].owner = map
	return return_dict