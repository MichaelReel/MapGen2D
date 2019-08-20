extends Control

class_name BaseItem

var icon : Sprite

func _ready():
	icon = $Sprite

func set_z_index(index : int):
	icon.z_index = index

func has_point(point) -> bool:
	return get_rect().has_point(point)