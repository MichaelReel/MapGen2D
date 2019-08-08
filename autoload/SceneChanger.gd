extends CanvasLayer

signal scene_changed()

onready var animation_player : AnimationPlayer = $AnimationPlayer
var current_scene : PackedScene

func change_scene_to(scene : PackedScene, focus: Node2D, new_pos: Vector2, delay : float = 0.5):
	# Remove player from the current scene (stop moving, dammit!)
	var node_2d = get_tree().get_root()
	if current_scene:
		node_2d.call_deferred("remove_child", focus)
	
	# Fade out current scene
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("fade")
	yield(animation_player, "animation_finished")
	
	# Load new scene and insert player
	assert(get_tree().change_scene_to(scene) == OK)
	current_scene = scene
	focus.position = new_pos
	node_2d.call_deferred("add_child", focus, true)
	
	# Fade in new scene
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")
