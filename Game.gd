extends Node2D

func _ready():
	# Create a starter node, and load it
	WorldGenerator.generate_world()
	print("Town generated: " + str(WorldGenerator.town))
	var player := WorldGenerator.generate_player()
	SceneChanger.change_scene_to(WorldGenerator.town, player, Vector2(16,16))
