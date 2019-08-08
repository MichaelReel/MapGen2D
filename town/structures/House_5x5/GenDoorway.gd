extends Node2D

func get_portal(offset: Vector2) -> Dictionary:
	# Handle the creation of graphics and collision areas
	# Return to let world gen handle linking and generation of other areas

	# Clone door
	var new_sprite = $Door.duplicate(DUPLICATE_SIGNALS + DUPLICATE_SCRIPTS + DUPLICATE_USE_INSTANCING)
	new_sprite.init_position(position + offset)
	print ("Exterior door " + str(new_sprite) + ",name: " + new_sprite.name + ", created from " + str($Door))
	return { "sprite" : new_sprite, "gen_script" : "res://town/structures/House_5x5/GenInterior.gd" }