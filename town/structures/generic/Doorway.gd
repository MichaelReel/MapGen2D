extends Node2D

class_name Doorway

func init_position(pos : Vector2):
	position = pos
	name = str(position)
	print("Setting (pos) name on " + str(self) + " to " + name)

func init_scene(parent : Node2D):
	name = str(parent) + "~" + str(position)
	print("Setting (scene) name on " + str(self) + " to " + name)

func _on_Area2D_body_entered(body):
	if body.get_parent() is Player:
		print("External doorway " + str(self) + ", name: " + name + ", entered by " + str(body))
		WorldGenerator.call_deferred("doorway_entered", self, body)
