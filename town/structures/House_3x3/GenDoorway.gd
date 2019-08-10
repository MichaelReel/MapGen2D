extends Node2D

func get_portal(offset: Vector2) -> Dictionary:
	# Handle the creation of graphics and collision areas
	# Return to let world gen handle linking and generation of other areas

	# Clone door
	var new_sprite = $Door.duplicate(DUPLICATE_SIGNALS + DUPLICATE_SCRIPTS + DUPLICATE_USE_INSTANCING)
	new_sprite.init_position(position + offset)
	return { "sprite" : new_sprite, "gen_script" : "res://town/structures/House_3x3/GenInterior.gd" }