extends Node2D

var world_state = {}
var move_commands = {}
var hostile_move_commands := Array()
var combat_commands := Array()
var moving_units := Array()
var move_count = 0
var move_size

enum COMBAT_TYPE { 
	assault,
	neutral
}

signal turn_ended
signal all_moved

var occupations = {
	"unit" : null,
	"faction" : null,
	"moving_to" : null 
}

func add_occupying_unit(unit, region_name, faction):
	world_state[region_name] = {"unit" : unit.get_path(), "faction" : faction, "moving_to": null}	

func erase_occupation(region, unit_path):
	if world_state.has(region.region_name):
		if world_state[region.region_name].unit == unit_path:
			world_state[region.region_name].unit = null
			world_state[region.region_name].moving_to = null
		#print("Removing any occupants to: " + region.region_name)

func add_standard_move_command(unit, destination_region):
	remove_command(unit)
	var command = {
		"destination_path": destination_region.get_path()
	}
	if not move_commands.has(unit.get_path()):
		move_commands[unit.get_path()] = command
		world_state[unit.current_region.region_name].moving_to = destination_region.get_path()

func remove_command(unit):
	var path = unit.get_path()
	if move_commands.has(path):
		move_commands.erase(path)

func reset_commands():
	move_commands.clear()
	hostile_move_commands.clear()
	combat_commands.clear()

# Turn sequence begins with friendly move actions. 
# All movement between friendly regions happens first.
# In this pass, we simple look over all commands and determine if there's going to be a move into a hostile region.
# If there is, we add this to a list of hostile moves.
# We then set a move command to all units who are moving into a friendly region. 
func process_turn_sequence(types):
	var units_to_move := Array()
	move_count = 0
	for unit_path in move_commands.keys():
		var can_move = false
		var unit = get_node(unit_path)
		var destination = get_node(move_commands[unit_path].destination_path)
		if world_state.has(destination.region_name):
			var region_state = world_state[destination.region_name]
			if region_state.faction == unit.faction:
				can_move = true
		if can_move:
			units_to_move.push_back(unit)
		else:
			hostile_move_commands.push_back(unit_path)
	
	move_units(units_to_move)
	yield(self, "all_moved")
	#print("World state after moves: " + str(world_state))
	call_deferred("process_hostile_moves", hostile_move_commands)

func process_hostile_moves(units):
	move_count = 0
	var units_to_move := Array()
	for unit_path in units:
		var can_move = true
		var combat = { "type" : null, "attacker" : unit_path, "defender": null}
		var unit = get_node(unit_path)
		var destination = get_node(move_commands[unit_path].destination_path)
		# What happens if two units move into an unoccupied region?
		if world_state.has(destination.region_name):
			var region_state = world_state[destination.region_name]
			if region_state.unit:
				combat.defender = region_state.unit
				combat.type = COMBAT_TYPE.assault
				can_move = false
				# Need to determine if the unit can move at the present moment in time. 
				if region_state.moving_to:
					can_move = (region_state.moving_to != unit.current_region.get_path()) \
					and can_move(get_node(region_state.moving_to), destination)
		if can_move:
			units_to_move.push_back(unit)
		else:
			if not has_combat_command(combat):
				combat_commands.push_back(combat)
				
	move_units(units_to_move)
	yield(self, "all_moved")
	#print("World state after hostile moves: " + str(world_state))
	process_combat()

# Going to implement combat one unit at a time to start.
func process_combat():
	var damaged_units := Array()
	for combat in combat_commands:
		var attacker_attk = get_node(combat.attacker).attack
		var defender_attk = get_node(combat.defender).attack
		add_damage(attacker_attk, combat.defender, damaged_units)
		add_damage(defender_attk, combat.attacker, damaged_units)
	
	var live_units := Array()

	if not damaged_units.empty():
		for unit in damaged_units:
			var curr_unit = get_node(unit.unit_p)
			var is_dead = curr_unit.on_damage_dealt(unit.damage)
			if not is_dead:
				live_units.push_back(unit.unit_p)
			else:
				erase_occupation(curr_unit.current_region, unit.unit_p)
	
	var units_to_move := Array()
	
	for unit in live_units:
		if move_commands.has(unit):
			var unit_dest = get_node(move_commands[unit].destination_path)
			if not world_state[unit_dest.region_name].unit and not world_state[unit_dest.region_name].moving_to:
				units_to_move.push_back(get_node(unit))
			else:
				get_node(unit).reset_move()
	
	move_units(units_to_move)
	yield(self, "all_moved")
	
	call_deferred("emit_signal","turn_ended")

func add_damage(damage, damaged_unit, damaged_units):
	if has_unit(damaged_unit, damaged_units):
		for unit in damaged_units:
			if unit.unit_p == damaged_unit:
				unit.damage += damage
				break
	else:
		damaged_units.push_back({
			"unit_p" : damaged_unit, 
			"damage" : damage
		})

func has_unit(unit, damaged_units):
	var has_unit = false
	for current_unit in damaged_units:
		if current_unit.unit_p == unit:
			has_unit = true
	return has_unit

func can_move(dest, curr_region):
	var can_move = true
	if world_state.has(dest.region_name):
		var region_state = world_state[dest.region_name]
		if region_state.unit and region_state.moving_to:
			if region_state.moving_to == curr_region.get_path():
				combat_commands.push_back({
					"type" : COMBAT_TYPE.neutral,
					"attacker" : world_state[curr_region.region_name].unit,
					"defender" : region_state.unit
				})
				can_move = false
	return can_move

func has_combat_command(combat):
	var has_command = false
	for command in combat_commands:
		if (combat.type == command.type) and (combat.attacker == command.attacker) and (combat.defender == command.defender):
			has_command = true
	return has_command

func move_units(units):
	if not units.empty():
		move_size = units.size()
		for unit in units:
			unit.connect("finished_move", self, "on_confirmed_move")
			var dest_node = get_node(move_commands[unit.get_path()].destination_path)
			erase_occupation(unit.current_region, unit.get_path())
			unit.move(dest_node)
	else:
		call_deferred("emit_signal", "all_moved")

func on_confirmed_move():
	move_count += 1
	if move_count == move_size:
		call_deferred("emit_signal", "all_moved")
