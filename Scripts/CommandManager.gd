extends Node2D

func process_command(regions):
	# Get the regions that need to be evaluated
	var evaluated_regions = regions.keys()
	# Iterate over all regions
	for region in evaluated_regions:
		var region_details = regions[region]
		var moving_units = region_details["moving"]
		var occupying_units = region_details["occupying"]
		# Check if there is more than one faction involved in this region.
		# If there is then there is most likely going to be a combat.
		if region_details["factions"].size() > 1:
			var victor = null
			var units_by_faction = {}
			# CASE 1: Two opposing players are moving into the same region
			if moving_units.size() > 1:
				# For each faction - get their units and combine their stats. 
				for faction in region_details["factions"]:
					var evaluated = Array()
					units_by_faction[faction] = get_combined_stats(get_units_from_faction(faction, moving_units))
					for stack in units_by_faction.values():
						# Make sure that units take damage ONCE from one another. 
						for other_stack in units_by_faction.values():
							# Stop unit from damaging itself and from damaging units that have already been damaged
							if other_stack != stack and not evaluated.has(other_stack):
								victor = deal_reciprocal_damage(stack, other_stack)
								# Set the current stack as damaged already
								evaluated.push_back(stack)
			elif occupying_units.size() > 0 and moving_units > 0:
				pass
			# Now take the damage taken and subtract it from all units in the stack
			for faction in units_by_faction.keys():
				# Get the current faction. 
				var faction_units = get_units_from_faction(faction, moving_units)
				var damage = units_by_faction[faction]["damage_taken"]
				var idx = 0
				# Make sure all damage is distributed amongst units
				while damage > 0:
					var unit = faction_units[idx]
					damage = unit.on_damage_dealt(damage)
					idx += 1
			if victor:
				# If there is a victor then move the units of the victor over.
				var victor_units = get_units_from_faction(victor["faction"], moving_units)
				move_units_in_group(victor_units, region)
		else:
			# If not combat has occurred then just move the units
			move_units_in_group(moving_units, region)

func move_units_in_group(unit_array, destination):
	for unit in unit_array:
		unit.move(destination)

func get_combined_stats(unit_array):
	var unit_stack = {
		"faction" : unit_array[0].faction,
		"defence" : 0,
		"attack" : 0,
		"health" : 0,
		"damage_taken" : 0
	}
	for unit in unit_array:
		unit_stack["defence"] += unit.defence
		unit_stack["attack"] += unit.attack
		unit_stack["health"] += unit.current_health
	return unit_stack

func get_units_from_faction(faction, unit_array):
	var faction_units = Array()
	for unit in unit_array:
		if unit.faction == faction:
			faction_units.push_back(unit)
	return faction_units

func damage_stack(stack, damage):
	stack["health"] -= damage
	stack["damage_taken"] += damage

func deal_reciprocal_damage(stack_a, stack_b):
	# Damage other stack
	damage_stack(stack_b, stack_a["attack"] - stack_b["defence"])
	# Take damage from the other stack
	damage_stack(stack_a, stack_b["attack"] - stack_a["defence"])
	return get_victor(stack_a, stack_b)

func get_victor(stack_a, stack_b):
	var victor = null
	if is_defeated(stack_a) and not is_defeated(stack_b):
		victor = stack_b
	if is_defeated(stack_b) and not is_defeated(stack_a):
		victor = stack_a
	return victor

func is_defeated(stack):
	return stack["health"] <= 0
