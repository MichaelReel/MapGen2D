extends Node2D

func _ready():
	# Create a starter node, and load it
	WorldGenerator.generate_world()
	print("Town generated: " + str(WorldGenerator.town))
	SceneChanger.change_scene_to(WorldGenerator.town)

