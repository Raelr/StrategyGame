extends Node2D

var world_state = {}
var move_commands = {}
var hostile_move_commands := Array()
var combat_commands := Array()
var moving_units := Array()
var move_count = 0
var move_size

signal turn_ended
signal all_moved

var occupations = {
	"unit" : null,
	"faction" : null
}

func add_occupying_unit(unit, region_name, faction):
	if not world_state.has(region_name):
		var occupation = {
			"unit" : unit.get_path(),
			"faction" : faction
		}
		world_state[region_name] = occupation
		print("Adding " + unit.name + " as occupying " + region_name)

func erase_occupation(region):
	if world_state.has(region.region_name):
		world_state[region.region_name].unit = null
		print("Removing any occupants to: " + region.region_name)

func add_standard_move_command(unit, destination_region):
	remove_command(unit)
	var command = {
		"destination_path": destination_region.get_path()
	}
	if not move_commands.has(unit.get_path()):
		move_commands[unit.get_path()] = command
		print("Setting move command for " + unit.name + " to " + destination_region.region_name)
		erase_occupation(unit.current_region)

func remove_command(unit):
	var path = unit.get_path()
	if move_commands.has(path):
		move_commands.erase(path)

func reset_commands():
	move_commands.clear()
	world_state.clear()
	hostile_move_commands.clear()
	combat_commands.clear()

func process_turn_sequence(types):
	var units_to_move := Array()
	move_count = 0
	for unit_path in move_commands.keys():
		var unit = get_node(unit_path)
		var destination = get_node(move_commands[unit_path].destination_path)
		if world_state.has(destination.region_name):
			var region_state = world_state[destination.region_name]
			if region_state.faction != unit.faction:
				print("Region is owned by a hostile!")
				hostile_move_commands.push_back(move_commands[unit_path])
				# In this case we'd log down that there needs to be combat in the destination region.
			else: 
				print("Region is occupied by friendly!")
				units_to_move.push_back(unit)
				# We can move safely.region_state
		else:
			print("Region is unoccupied")
			hostile_move_commands.push_back(move_commands[unit_path])
	
	move_units(units_to_move)
	yield(self, "all_moved")
	call_deferred("emit_signal","turn_ended")

func move_units(units):
	if not units.empty():
		move_size = units.size()
		for unit in units:
			print(unit.name)
			unit.connect("finished_move", self, "on_confirmed_move")
			var dest_node = get_node(move_commands[unit.get_path()].destination_path)
			unit.move(dest_node)

func on_confirmed_move():
	move_count += 1
	if move_count == move_size:
		print("All units have been moved!")
		call_deferred("emit_signal", "all_moved")
