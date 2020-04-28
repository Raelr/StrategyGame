extends Node2D

var world_state = {}
var commands := Array()

var occupations = {
	"unit" : null
}

func add_occupying_unit(unit, region):
	if not world_state.has(region):
		world_state[region] = unit.get_path()
		print("Registering unit: " + unit.name + " as occupying: " + region.region_name)

# This will be the entry which deals with unit movement and prioritisation. 

# var move_command = {
#	 "unit" : null,
#	 "destination" : null,
# 	 "speed" : 0
# }

# When registering a unit, add their details to the region_state table
# This should provide details about the region's occupation details
# Key should be the region's name (Weslund, Ososia...etc)

# var region_state = {
# 	region: NodePath (region)
# 	occupier: NodePath (unit)
#	occupying_faction: faction (enum)
#	bonus : 0
# }

# TODO: Change setup to work with new plan.
# TODO: Add region_state for every region (or at least those with units in them) to world_state.
# TODO: Add move commands when right clicking units. 
# TODO: Add ability to remove element from heap (for when a command is not fully set)

func register_region(region, unit):
	pass

func add_standard_move(region, unit):
	pass
