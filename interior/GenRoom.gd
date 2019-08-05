extends Node2D

onready var player : = $Player

func _on_Area2D_body_entered(body):
	 # This a bit specific and potentially flaky, need to thing about this a bit:
	if player == body.get_parent():
		print("player entered portal")
		player.pause()
		
		# For now just do a rough transition to the 'root' map
		SceneChanger.change_scene("res://town/GenMap.tscn")


func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	print("body_id: " + str(body_id))
	print("body: " + str(body))
	print("body_shape: " + str(body_shape))
	print("area_shape: " + str(area_shape))
