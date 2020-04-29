extends Node2D

var world_state = {}
var move_commands = {}
var hostile_move_commands := Array()
var combat_commands := Array()

signal turn_ended

var occupations = {
	"unit" : null
}

func add_occupying_unit(unit, region_name):
	if not world_state.has(region_name) or world_state[region_name] == null:
		world_state[region_name] = unit.get_path()
		print("Adding " + unit.name + " as occupying " + region_name)

func erase_occupation(region):
	if world_state.has(region.region_name):
		world_state[region.region_name] = null
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

func process_turn_sequence(types):
	for unit_path in move_commands.keys():
		var unit = get_node(unit_path)
		var destination = get_node(move_commands[unit_path].destination_path)
		if world_state.has(destination.region_name):
			if world_state[destination.region_name]:
				print("Region is occupied")
				var opposing_unit = get_node(world_state[destination.region_name])
				if opposing_unit.faction != unit.faction:
					print("Region is occupied by hostile!")
				else: 
					print("Region is occupied by friendly!")
			else:
				print("Region is unoccupied")
		else:
			print("region is unoccupied - can move the unit now!")
	call_deferred("emit_signal","turn_ended")
