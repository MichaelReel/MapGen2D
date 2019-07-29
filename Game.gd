extends Node2D

func _ready():
	# Create a starter node, and load it
	SceneChanger.change_scene("res://town/GenMap.tscn", 0.0)
	
