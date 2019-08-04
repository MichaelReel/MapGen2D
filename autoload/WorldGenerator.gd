extends Node

var town : PackedScene

func generate_world():
	# Ugh, need to provide the seeds some other way
	var town_seed := 1
	
	# Create a town map and get all portals
	var town_generator := TownGen.new()
	var town_dict = town_generator.generate_town(town_seed)
	town = town_dict["scene"]
	
	# Invoke generation on all the portals by gen type
	var town_portals : Array = town_dict["portals"]
	for portal_dict in town_portals:
		var sprite = portal_dict["sprite"]
		var script_path = portal_dict["gen_script"]
		# TODO: Use the gen_script to get a new packed scene, with return portal
		var gen = load(script_path).new()
		if gen.has_method("generate"):
			var gen_dict = gen.generate()
		
		# TODO: Create a link between the portal sprites