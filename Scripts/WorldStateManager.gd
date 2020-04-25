extends Node2D

var world_state = {}

# Outline of world_state storage variable.
# var region_state = {
#	 "factions" : Array(),
#	 "occupying" : Array(),
#	 "moving": Array()
# }

# Outline of movement variable
# var moving_unit = {
# 	 "moving_from" : null,
# 	 "moving_to" : null,
# 	 "speed" : 0
# }

func add_occupying_unit(unit):
	pass

func add_region(region):
	if not world_state.has(region):
		world_state[region] = {
			"factions" : Array(),
			"occupying" : Array(),
			"moving" : {}
		}
	print("Region: " + region.region_name + " added to world_state!")

func add_moving_units(current_region, destination_region, faction, unit):
	if world_state.has(region):
		

func remove_empty_regions(region):
	if world_state.has(region):
		if no_factions(world_state[region]):
			world_state.erase(region)

func no_factions(region_state):
	return region_state.factions.empty()

func no_occupations(region_state):
	return region_state.occupying.empty()

func no_moving_units(region_state):
	return region_state.moving.empty()
		
