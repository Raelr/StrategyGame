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
	if not world_state.has(region_name):
		var occupation = {
			"unit" : unit.get_path(),
			"faction" : faction,
			"moving_to": null
		}
		world_state[region_name] = occupation
		print("Adding " + unit.name + " as occupying " + region_name)

func erase_occupation(region):
	if world_state.has(region.region_name):
		world_state[region.region_name].unit = null
		world_state[region.region_name].moving_to = null
		print("Removing any occupants to: " + region.region_name)

func add_standard_move_command(unit, destination_region):
	remove_command(unit)
	var command = {
		"destination_path": destination_region.get_path()
	}
	if not move_commands.has(unit.get_path()):
		move_commands[unit.get_path()] = command
		world_state[unit.current_region.region_name].moving_to = destination_region.get_path()
		print("Setting move command for " + unit.name + " to " + destination_region.region_name)

func remove_command(unit):
	var path = unit.get_path()
	if move_commands.has(path):
		move_commands.erase(path)

func reset_commands():
	move_commands.clear()
	world_state.clear()
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
			units_to_move.push_back(unit_path)
		else:
			hostile_move_commands.push_back(unit_path)
	if not units_to_move.empty():
		move_units(units_to_move)
		yield(self, "all_moved")
	process_hostile_moves(hostile_move_commands)

func process_hostile_moves(units):
	move_count = 0
	var units_to_move := Array()
	for unit_path in units:
		var can_move = true
		var combat = { "type" : null, "attacker" : unit_path, "defender": null}
		var unit = get_node(unit_path)
		var destination = get_node(move_commands[unit_path].destination_path)
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
			combat_commands.push_back(combat)
	if not units_to_move.empty():
		move_units(units_to_move)
		yield(self, "all_moved")
	call_deferred("emit_signal","turn_ended")

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

func move_units(units):
	if not units.empty():
		move_size = units.size()
		for unit in units:
			unit.connect("finished_move", self, "on_confirmed_move")
			var dest_node = get_node(move_commands[unit.get_path()].destination_path)
			erase_occupation(unit.current_region)
			unit.move(dest_node)

func on_confirmed_move():
	move_count += 1
	if move_count == move_size:
		print("All units have been moved!")
		call_deferred("emit_signal", "all_moved")
