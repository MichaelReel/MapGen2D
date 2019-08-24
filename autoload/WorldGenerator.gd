extends Node

var portal_links : Dictionary
var scene_library : Dictionary # This allows re-storing an used scene after use
var current_scene_name : String

func doorway_entered(door : Node2D, body: Node2D):
	if body.get_parent() is Player:
		var player := body.get_parent()
		var port : Dictionary = portal_links[door.name]
	
		# TODO: I feel like there's a lack of error checking here
		SceneChanger.change_scene_to(port, player)

func generate_player() -> Player:
	var player := load("res://player/Player.tscn").instance() as Player
	player.set_name("Player")
	player.z_index = TilemapUtils.INTERACTION_Z_LAYER
	return player

func generate_world(world_seed : int = 5):
	# Generate seeds for each component randomly
	var rand = RandomNumberGenerator.new()
	rand.seed = world_seed
	var town_seed : int = rand.randi()
	
	# Create a town map and get all portals
	var town_generator := TownGen.new()
	var town_dict = town_generator.generate_town(town_seed)
	var town = town_dict["scene"]
	var town_bounds = town_dict["scene_bounds"]
	
	# Store the town as the starting scene, with a lookup key
	var town_name = str(town)
	update_scene_library(town_name, town)
	current_scene_name = town_name
	
	# Invoke generation on all the portals by gen type
	var town_portals : Array = town_dict["portals"]
	for portal_dict in town_portals:
		var sprite = portal_dict["sprite"]
		var script_path = portal_dict["gen_script"]
		
		# Use the gen_script to get a new packed scene, with return portal
		var gen = load(script_path).new()
		if gen.has_method("generate"):
			var room_seed : int = rand.randi()
			var gen_dict : Dictionary = gen.generate(room_seed)
			var room_scene : PackedScene = gen_dict["scene"]
			var room_bounds : Rect2 = gen_dict["scene_bounds"]
			var room_portal : Node2D = gen_dict["return_portal"]
			
			# Store room, with a lookup key
			var room_name = str(room_scene)
			update_scene_library(room_name, room_scene)
			
			# Get inside of the doorway
			var entry_coords : Vector2 = room_portal.position
			if room_portal.has_node("ExitUp"):
				entry_coords += room_portal.get_node("ExitUp").position
				
			# Get outside of the doorway
			var exit_coords : Vector2 = sprite.position
			if sprite.has_node("ExitDown"):
				exit_coords += sprite.get_node("ExitDown").position
			
			# Create a link between the portal sprites
			portal_links[sprite.name] = { "target_name" : room_name, "target_coords" : entry_coords, "bounds" : room_bounds }
			portal_links[room_portal.name] = { "target_name" : town_name, "target_coords" : exit_coords, "bounds" : town_bounds }

func update_scene_library(key : String, scene : PackedScene):
	scene_library[key] = scene
	
func get_scene_library(key : String) -> PackedScene:
	return scene_library[key]