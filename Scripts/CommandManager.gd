extends Node2D

signal combat_ended

func process_command(regions, types):
	# Get the regions that need to be evaluated
	var evaluated_regions = regions.keys()
	# Iterate over all regions
	for region in evaluated_regions:
		var region_details = regions[region]
		var moving_units = region_details["moving"]
		var occupying_units = region_details["occupying"]
		#print("Units occupying region: " + region.region_name + " " + str(occupying_units))
		#print("Units moving to region: " + region.region_name + " " + str(moving_units))
		var factions = region_details["factions"]
		# Check if there is more than one faction involved in this region.
		# If there is then there is most likely going to be a combat.
		if factions.size() > 1:
			var victor = null
			var units_by_faction = {}
			# CASE 1: Two opposing players are moving into the same region
			if moving_units.size() > 1 and occupying_units.empty():
				# For each faction - get their units and combine their stats. 
				for faction in factions:
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
			# CASE 2: A player attacks a unit occupying a region
			elif not occupying_units.empty() and not moving_units.empty():
				# Get the information about the defending faction. 
				var defending_faction = occupying_units[0].faction
				var reinforcements = get_units_from_faction(defending_faction, moving_units)
				units_by_faction[defending_faction] = get_combined_stats(get_units_from_faction(defending_faction, occupying_units))
				var defending_stack = units_by_faction[defending_faction]
				# Get the attacking factions
				var attacking_factions = Array()
				for faction in factions:
					if faction != defending_faction:
						attacking_factions.push_back(faction)
				victor = process_attack(units_by_faction, attacking_factions, defending_stack, moving_units, types[region.region_type].bonus)
				distribute_damage(occupying_units, defending_stack["damage_taken"], types[region.region_type].bonus)
				# If the attacker was unable to kill the defending unit...
				if not victor:
					if not reinforcements.empty():
						for unit in reinforcements:
							defending_stack["attack"] += unit.attack
							defending_stack["health"] += unit.current_health
					# Defender counterattacks...
					victor = process_attack(units_by_faction, attacking_factions, defending_stack, moving_units, 0, true)
					units_by_faction.erase(defending_faction)
				for faction in units_by_faction.keys():
					# Get the current faction. 
					var faction_units = get_units_from_faction(faction, moving_units) + get_units_from_faction(faction, occupying_units)
					var damage = units_by_faction[faction]["damage_taken"]
					# Make sure all damage is distributed amongst units
					distribute_damage(faction_units, damage)
			if victor:
				# If there is a victor then move the units of the victor over.
				move_units_in_group(get_units_from_faction(victor["faction"], moving_units), region)
		else:
			# If not combat has occurred then just move the units
			move_units_in_group(moving_units, region)
	emit_signal("combat_ended")

func move_units_in_group(unit_array, destination):
	for unit in unit_array:
		unit.move(destination)
		yield(unit, "finished_move")

func get_combined_stats(unit_array):
	var unit_stack = {
		"faction" : unit_array[0].faction,
		"attack" : 0,
		"health" : 0,
		"damage_taken" : 0,
	}
	for unit in unit_array:
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
	damage_stack(stack_b, stack_a["attack"])
	# Take damage from the other stack
	damage_stack(stack_a, stack_b["attack"])
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

func distribute_damage(units, damage, defence_bonus = 0):
	var idx = 0
	var size = units.size()
	var damage_by_unit = damage / size
	if damage_by_unit == 0:
		damage_by_unit = 1
	print("Damage: " + str(damage_by_unit))
	print("defence_bonus: " + str(defence_bonus))
	while idx != size:
		var unit = units[idx]
		unit.on_damage_dealt(damage_by_unit, defence_bonus)
		idx += 1

func process_attack(units_by_faction, factions, defender, units, defender_bonus = 0, is_counterattack = false):
	# Attack with the attacking factions
	var victor
	for faction in factions:
		units_by_faction[faction] = get_combined_stats(get_units_from_faction(faction, units))
		var attacking_stack = units_by_faction[faction]
		if is_counterattack:
			damage_stack(attacking_stack, defender["attack"])
			victor = defender
		else:
			damage_stack(defender, attacking_stack["attack"])
			victor = get_victor(attacking_stack, defender)
	return victor
