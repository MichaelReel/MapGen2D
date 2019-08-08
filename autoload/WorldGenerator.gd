extends Node

var town : PackedScene
var portal_links : Dictionary

func doorway_entered(door : Node2D, body: Node2D):
	if body.get_parent() is Player:
		var doorway := door as Doorway
		print ("Doorway " + str(door) + " entered, name: " + door.name + ", body: " + str(body))
		var player = body.get_parent()
		SceneChanger.change_scene_to(portal_links[door.name]["target_scene"], player, portal_links[door.name]["target_coords"])
		

func generate_player() -> Player:
	var player := load("res://player/Player.tscn").instance() as Player
	player.set_name("Player")
	return player

func generate_world():
	# Ugh, need to provide the seeds some other way
	var town_seed := 1
	
	# Create a town map and get all portals
	var town_generator := TownGen.new()
	var town_dict = town_generator.generate_town(town_seed)
	town = town_dict["scene"]
	
	# Invoke generation on all the portals by gen type
	var town_portals : Array = town_dict["portals"]
	for portal_dict in town_portals:
		var sprite = portal_dict["sprite"]
		var script_path = portal_dict["gen_script"]
		
		# Use the gen_script to get a new packed scene, with return portal
		var gen = load(script_path).new()
		if gen.has_method("generate"):
			var room_seed := 1
			var gen_dict : Dictionary = gen.generate(room_seed)
			var room_scene : PackedScene = gen_dict["scene"]
			var room_portal : Node2D = gen_dict["return_portal"]
			# Get inside of the doorway
			var entry_coords : Vector2 = room_portal.position
			if room_portal.has_node("Return"):
				entry_coords += room_portal.get_node("Return").position
			# Get outside of the doorway
			var exit_coords : Vector2 = sprite.position
			if sprite.has_node("Return"):
				exit_coords += sprite.get_node("Return").position
			
			# Create a link between the portal sprites
			print ("Linking portals: " + str(town) + "~" + str(exit_coords) + " -> " + str(room_scene) + "~" + str(entry_coords))
			portal_links[sprite.name] = { "target_scene" : room_scene, "target_coords" : entry_coords }
			portal_links[room_portal.name] = { "target_scene" : town, "target_coords" : exit_coords }
