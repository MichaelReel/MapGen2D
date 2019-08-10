extends CanvasLayer

signal scene_changed()

onready var animation_player : AnimationPlayer = $AnimationPlayer
var current_scene : PackedScene

func change_scene_to(portal : Dictionary, focus: Node2D, delay : float = 0.0):
	var node_2d = get_tree().get_root()
	var scene = portal["target_scene"]
	var new_pos = portal["target_coords"]
	var bounds = portal["bounds"]
	
	# stop moving, dammit!
	if focus.has_method("freeze"):
		focus.freeze()
	
	if current_scene:
		# Fade out current scene
		yield(get_tree().create_timer(delay), "timeout")
		animation_player.play("fade")
		yield(animation_player, "animation_finished")
	
		node_2d.call_deferred("remove_child", focus)
	
	# Load new scene and insert player
	assert(get_tree().change_scene_to(scene) == OK)
	current_scene = scene
	focus.position = new_pos
	node_2d.call_deferred("add_child", focus, true)
	
	# Set camera limits depending on map expanse
	if focus.has_method("set_view_tile_bounds"):
		focus.set_view_tile_bounds(bounds)
	
	# Fade in new scene
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")
	
	if focus.has_method("thaw"):
		focus.thaw()
