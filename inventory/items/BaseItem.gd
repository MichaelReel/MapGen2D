extends Node

class_name BaseItem

var icon : Sprite

func _ready():
	icon = $Sprite

func get_icon() -> Sprite:
	return icon
