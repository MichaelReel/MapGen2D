extends CanvasLayer

signal scene_changed()

onready var animation_player := $AnimationPlayer

func change_scene(path : String, delay := 0.5):
	change_scene_to(load(path), delay)

func change_scene_to(scene : PackedScene, delay := 0.5):
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("fade")
	yield(animation_player, "animation_finished")
	assert(get_tree().change_scene_to(scene) == OK)
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")
