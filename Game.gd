extends Node2D

func _ready():
	# Create a starter node, and load it
	WorldGenerator.generate_world()
	print("Town generated: " + str(WorldGenerator.town))
	var player := WorldGenerator.generate_player()
	
	var player_start : Dictionary
	for portkey in WorldGenerator.portal_links.keys():
		if WorldGenerator.portal_links[portkey]["target_scene"] == WorldGenerator.town:
			player_start = WorldGenerator.portal_links[portkey]
			break
	
	SceneChanger.change_scene_to(player_start, player)
