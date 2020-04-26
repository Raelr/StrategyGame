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

func add_region(region):
	if not world_state.has(region):
		world_state[region] = {
			"factions" : Array(),
			"occupying" : Array(),
			"moving" : {}
		}
		print("Region: " + region.region_name + " added to world_state!")

func add_moving_units(current_region, destination_region, faction, unit):
	remove_previous_moves(unit, faction)
	add_region(destination_region)
	if not world_state[destination_region].moving.has(unit):
		world_state[destination_region].moving[unit] = {
			"moving_from" : current_region,
			"speed" : 0
		}
		if not world_state[destination_region].factions.has(faction):
			world_state[destination_region].factions.push_back(faction)

		print("Added " + unit.name + " as moving to region: " + destination_region.region_name +  " from: " + current_region.region_name)
		print("With speed: " + str(0))

func remove_previous_moves(unit, faction):
	var neighbours = unit.get_possible_paths()
	for neighbour in neighbours:
		if world_state.has(neighbour):
			if world_state[neighbour].moving.has(unit):
				world_state[neighbour].moving.erase(unit)
				print("\nRemoving move command for " + unit.name + " to move to: " + neighbour.region_name)
				if not faction_in_region(faction, neighbour):
					world_state[neighbour].factions.erase(faction)
				if no_moving_units(world_state[neighbour]):
					if no_occupations(world_state[neighbour]):
						remove_empty_regions(neighbour)

func add_occupying_unit(unit, faction, region):
	add_region(region)
	if not world_state[region].occupying.has(unit):
		world_state[region].occupying.push_back(unit)
		if not world_state[region].factions.has(faction):
			world_state[region].factions.push_back(faction)
	print("Added " + unit.name + " as occupying region: " + region.region_name)

func remove_previous_occupations(unit, faction, region):
	if world_state.has(region):
		if world_state[region].occupying.has(unit):
			world_state[region].occupying.erase(unit)
		if world_state[region].occupying.empty():
			world_state[region].factions.erase(faction)
		print("Removed unit: " + unit.name + " from occupying region: " + region.region_name)

func faction_in_region(faction, region):
	var has_faction = false
	for unit in world_state[region].moving.keys():
		if unit.faction == faction:
			has_faction = true
			print("Faction: " + str(faction) + " still exists in region!")
	print("Does faction still exist in region? " + str(has_faction))
	return has_faction

func remove_empty_regions(region):
	if world_state.has(region):
		if no_factions(world_state[region]):
			world_state.erase(region)
			print("Removing region: " + region.region_name + " from world state!")

func no_factions(region_state):
	return region_state.factions.empty()

func no_occupations(region_state):
	return region_state.occupying.empty()

func no_moving_units(region_state):
	return region_state.moving.empty()
		
