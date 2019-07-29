extends CanvasLayer

signal scene_changed()

onready var animation_player := $AnimationPlayer
onready var black := $Control/Black

func change_scene(path : String, delay := 0.5):
	# Wait before fade
	yield(get_tree().create_timer(delay), "timeout")
	# Fade and wait for that to finish
	animation_player.play("fade")
	yield(animation_player, "animation_finished")
	# Load the new scene
	assert(get_tree().change_scene(path) == OK)
	# Fade the new scene in
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	# Signal that we're done
	emit_signal("scene_changed")
