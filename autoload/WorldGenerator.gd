extends Node

var town : PackedScene

func generate_world():
	# Ugh, need to provide the seeds some other way
	var town_seed := 1
	
	# Create a town map and get all portals
	var town_generator := TownGen.new()
	town = town_generator.generate_town(town_seed)