extends CanvasLayer

signal scene_changed()

onready var animation_player := $AnimationPlayer

func change_scene(path : String, focus: Node2D, delay := 0.5):
	change_scene_to(load(path), focus, delay)

func change_scene_to(scene : PackedScene, focus: Node2D, delay := 0.5):
	# Fade out current scene
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("fade")
	yield(animation_player, "animation_finished")
	
	# Load new scene and insert player
	assert(get_tree().change_scene_to(scene) == OK)
	var node_2d = get_tree().get_root()
	node_2d.add_child(focus, true)
	focus.owner = node_2d
	
	# Fade in new scene
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")
