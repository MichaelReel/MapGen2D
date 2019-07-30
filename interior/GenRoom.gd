extends Node2D

onready var player : = $Player

func _on_Area2D_body_entered(body):
	 # This a bit specific and potentially flaky, need to thing about this a bit:
	if player == body.get_parent():
		print("player entered portal")
		player.pause()
		
		# For now just do a rough transition to the 'root' map
		SceneChanger.change_scene("res://town/GenMap.tscn")
