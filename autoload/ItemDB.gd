extends Node

const ITEM_PATH = "res://inventory/items/"

var ERROR : Resource
var ITEMS := {}

func _ready():
	# Get the list of scenes from them items directory
	var dir := Directory.new()
	assert(dir.open(ITEM_PATH) == OK)
	assert(dir.list_dir_begin() == OK)
	var file_name := dir.get_next()
	while (file_name != ""):
		if file_name.ends_with(".tscn"):
			# Get the error object ready for bad item calls
			if file_name.begins_with("Error"):
				ERROR = load(ITEM_PATH + file_name)
				print("ERROR set to " + str(ERROR) + " : " + file_name)
			else:
				ITEMS[file_name.get_basename()] = load(ITEM_PATH + file_name)
				print(file_name.get_basename() + " set to " + str(ITEMS[file_name.get_basename()]) + " : " + file_name)
		file_name = dir.get_next()

func get_item_resource(item_id : String) -> Resource:
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ERROR

func get_item(item_id : String) -> Node2D:
	return get_item_resource(item_id).instance()
