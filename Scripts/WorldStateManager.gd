extends Node2D

var world_state = {}
var commands := Array()

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

func add_region(region):
	if not world_state.has(region):
		world_state[region] = {
			"factions" : Array(),
			"occupying" : Array(),
			"moving" : {}
		}
		#print("Region: " + region.region_name + " added to world_state!")

func add_moving_units(current_region, destination_region, faction, unit, types):
	remove_previous_moves(unit, faction)
	remove_previous_occupations(unit, faction, current_region)
	add_region(destination_region)
	if not world_state[destination_region].moving.has(unit):
		world_state[destination_region].moving[unit] = {
			"moving_from" : current_region,
			"moving_to" : null,
			"speed" : unit.speed
		}
		add_region(current_region)
		world_state[current_region].moving[unit] = {
			"moving_from" : null,
			"moving_to" : destination_region,
			"speed" : unit.speed + types[current_region.region_type].bonus
		}
		if not world_state[current_region].factions.has(faction):
			world_state[current_region].factions.push_back(faction)
		if not world_state[destination_region].factions.has(faction):
			world_state[destination_region].factions.push_back(faction)
	
		#print("Added " + unit.name + " as moving to region: " + destination_region.region_name +  " from: " + current_region.region_name)
		#print("With speed: " + str(0))
		
		# Determine if a combat will happen based on this!
		var state = world_state[destination_region]
		if state.factions.size() > 1:
			print("COMBAT WILL LIKELY OCCUR IN REGION: " + destination_region.region_name)
			if not state.moving.keys().empty() and not state.occupying.empty():
				print("LIKELY ASSAULT ON REGION")
			elif state.occupying.empty() and state.moving.keys().size() > 1:
				if occupier_is_moving(state):
					print("A CHASE IS LIKELY GOING TO HAPPEN!")
					var moving_enemies = get_moving_units(state, faction)
				else:
					print("LIKELY TWO ENEMIES WALKING INTO SAME REGION")

func get_units_moving_in(state, faction):
	var units_moving_in = Array()
	for unit in state.moving.keys():
		if state.moving[unit].moving_from and unit.faction == faction:
			units_moving_in.push_back(unit)
	return units_moving_in

func get_moving_units(state, faction):
	var moving_enemy_units = Array()
	for unit in state.moving.keys():
		if state.moving[unit].moving_to and unit.faction != faction:
			moving_enemy_units.push_back(unit)
	return moving_enemy_units

func occupier_is_moving(state):
	var is_moving = false
	for unit in state.moving.keys():
		if state.moving[unit].moving_to:
			is_moving = true
	return is_moving

func remove_previous_moves(unit, faction):
	var neighbours = unit.get_possible_paths()
	for neighbour in neighbours:
		if world_state.has(neighbour):
			if world_state[neighbour].moving.has(unit):
				world_state[neighbour].moving.erase(unit)
				#print("\nRemoving move command for " + unit.name + " to move to: " + neighbour.region_name)
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
	
	#print("Added " + unit.name + " as occupying region: " + region.region_name)

func remove_previous_occupations(unit, faction, region):
	if world_state.has(region):
		if world_state[region].occupying.has(unit):
			world_state[region].occupying.erase(unit)
		if world_state[region].occupying.empty() and not faction_in_region(faction, region):
			world_state[region].factions.erase(faction)
		#print("Removed unit: " + unit.name + " from occupying region: " + region.region_name)

func faction_in_region(faction, region):
	var has_faction = false
	for unit in world_state[region].moving.keys():
		if unit.faction == faction:
			has_faction = true
			#print("Faction: " + str(faction) + " still exists in region!")
	#print("Does faction still exist in region? " + str(has_faction))
	#return has_faction

func remove_empty_regions(region):
	if world_state.has(region):
		if no_factions(world_state[region]):
			world_state.erase(region)
			#print("Removing region: " + region.region_name + " from world state!")

func no_factions(region_state):
	return region_state.factions.empty()

func no_occupations(region_state):
	return region_state.occupying.empty()

func no_moving_units(region_state):
	return region_state.moving.empty()

func add_element(command):
	if not commands.empty():
		var idx = commands.size()
		commands.push_back(command)
		sort_up(command, idx)

func sort_up(command, start_idx):
	var parent_idx : int = (start_idx - 1) / 2
	
	while true:
		var parent = commands[parent_idx]
		if command.speed > parent.speed:
			swap(command, start_idx, parent, parent_idx)
			start_idx = parent_idx
		else:
			break
		parent_idx = (start_idx - 1) / 2

func remove_first():
	var first_item = commands.front()
	commands[0] = commands.back()
	commands.pop_back()
	sort_down(commands.front())
	return first_item

func find(unit): 
	pass

func sort_down(command, start_idx = 0):
	var size : int = commands.size()
	var child_idx_left: int = (start_idx * 2) + 1
	var child_idx_right: int = (start_idx * 2) + 2
	var swap_idx: int = 0
	
	if child_idx_left < size:
		swap_idx = child_idx_left
		if child_idx_right < size:
			if commands[child_idx_left] < commands[child_idx_right]:
				swap_idx = child_idx_right
		if command.speed < commands[swap_idx]:
			swap(command, start_idx, commands[swap_idx], swap_idx)
			start_idx = swap_idx
		else:
			return
	else:
		return

func swap(command_a, command_a_idx, command_b, command_b_idx):
	commands[command_a_idx] = command_b
	commands[command_b_idx] = command_a
