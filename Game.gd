extends Node2D

func _ready():
#	SceneChanger.change_scene("res://town/GenMap.tscn", 0.0)
#	SceneChanger.change_scene("res://interior/GenRoom.tscn", 0.0)

	# Create a starter node, and load it
	WorldGenerator.generate_world()
	print("Town generated: " + str(WorldGenerator.town))
	SceneChanger.change_scene_to(WorldGenerator.town)

