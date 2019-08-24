extends Node2D

func _ready():
	# Create a starter node, and load it
	WorldGenerator.generate_world()
	var player := WorldGenerator.generate_player()
	
	# This should probably be handled by the world builder:
	var player_start : Dictionary
	for portkey in WorldGenerator.portal_links.keys():
		if WorldGenerator.portal_links[portkey]["target_name"] == WorldGenerator.current_scene_name:
			player_start = WorldGenerator.portal_links[portkey]
			break
	
	SceneChanger.change_scene_to(player_start, player)

