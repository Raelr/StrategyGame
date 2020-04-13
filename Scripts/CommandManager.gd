extends Node2D


# ----------> MOVE BELOW CODE TO A NEW NODE vvvvvv

func process_command(regions):
	# Get the regions that need to be evaluated
	var evaluated_regions = regions.keys()
	# Iterate over all regions
	for region in evaluated_regions:
		var region_details = regions[region]
		var moving_units = region_details["moving"]
		# Check if there is more than one unit moving into a region. If there is,
		# check if there is any combat that needs to occur.
		# CASE 1: Two opposing players are moving into the same region
		if moving_units.size() > 1:
			# Check for the factions involved in this.
			if region_details["factions"].size() > 1:
				var units_by_faction = {}
				var victor = null
				# For each faction - get their units and combine their stats. 
				for faction in region_details["factions"]:
					var evaluated = Array()
					units_by_faction[faction] = get_combined_stats(get_units_from_faction(faction, moving_units))
					for stack in units_by_faction.values():
						# Make sure that units take damage ONCE from one another. 
						for other_stack in units_by_faction.values():
							# Stop unit from damaging itself and from damaging units that have already been damaged
							if other_stack != stack and not evaluated.has(other_stack):
								# Damage other stack
								var damage = stack["attack"] - other_stack["defence"]
								other_stack["health"] -= damage
								other_stack["damage_taken"] += damage
								# Take damage from the other stack
								damage = other_stack["attack"] - stack["defence"]
								stack["health"] -= damage
								stack["damage_taken"] += damage
								# Set the current stack as damaged already
								evaluated.push_back(stack)
								# Check if a side has won. 
								if other_stack["health"] == 0 and stack["health"] > 0:
									victor = stack
								elif other_stack["health"] > 0 and stack["health"] == 0:
									victor = other_stack
								if victor: 
									break
					# Now take the damage taken and subtract it from all units in the stack
					for faction in units_by_faction.keys():
						# Get the current faction. 
						var stack = units_by_faction[faction]
						var faction_units = get_units_from_faction(faction, moving_units)
						var damage = stack["damage_taken"]
						var idx = 0
						# Make sure all damage is distributed amongst units
						while damage > 0:
							if faction_units.empty():
								break
							var unit = faction_units[idx]
							# Get an estimate on whether the damage will kill the unit or not
							var projected_damage = unit.current_health - damage
							# if the damage will kill the unit
							if projected_damage <= 0:
								damage -= unit.current_health
								unit.current_health = 0
								# Make sure to remove the unit from the game
								unit.on_death()
							else:
								# Remove the damage from the unit's health and move on
								unit.current_health -= damage
								damage -= unit.current_health
							idx += 1
				if victor:
					# If there is a victor then move the units of the victor over.
					var victor_units = get_units_from_faction(victor["faction"], moving_units)
					for unit in victor_units:
						unit.destination = region
						unit.move()
		# If not combat has occurred then just move the units
		else:
			for unit in moving_units:
				unit.destination = region
				unit.move()

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

# -------------> MOVE ABOVE CODE TO A NEW NODE ^^^^^
