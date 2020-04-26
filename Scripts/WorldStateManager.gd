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

func register_region(region, unit):
	pass

func add_move_command(region, unit):
	pass

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
	if not commands.empty():
		var idx = 0
		for command in commands:
			if get_node(command.unit) == unit:
				return idx
			else:
				idx+= 1

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
