extends Node2D

class_name Doorway

func init_position(pos : Vector2):
	position = pos
	name = str(position)

func init_scene(parent : Node2D):
	name = str(parent) + "~" + str(position)

func _on_Area2D_body_entered(body):
	if body.get_parent() is Player:
		WorldGenerator.call_deferred("doorway_entered", self, body)
		open()

func open():
	$AnimationPlayer.play("open")