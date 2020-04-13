extends Node2D

enum SELECTED {region, unit}
enum FACTIONS {player, neutral}
var moused_elements = Array()
var selected = null
var selected_type
var ui_moused_over = false

signal on_turn_changed

var units = Array()

var regions = {}

func _ready():
	$Camera2D/CanvasLayer/Popup.connect("on_button_mouseover", self, "set_ui_moused_over")
	$Camera2D/CanvasLayer/Popup.connect("on_button_exit", self, "set_ui_moused_exit")
	$Camera2D/CanvasLayer/RegionPanel.connect("on_button_mouseover", self, "set_ui_moused_over")
	$Camera2D/CanvasLayer/RegionPanel.connect("on_button_exit", self, "set_ui_moused_exit")
	$Camera2D/CanvasLayer/RegionPanel.connect("on_button_close", self, "disable_region_ui")
	$Camera2D/CanvasLayer/UnitPanel.connect("on_button_exit", self, "set_ui_moused_exit")
	$Camera2D/CanvasLayer/UnitPanel.connect("on_button_close", self, "disable_region_ui")

func disable_ui():
	$Camera2D/CanvasLayer/UnitPanel.deactivate_panel()
	$Camera2D/CanvasLayer/RegionPanel.deactivate_panel()
	reset_selected()

func disable_panel(panel):
	panel.deactivate_panel()
	reset_selected()

func register_move_command(region, faction, unit):
	if not regions.has(region):
		regions[region] = {
			"factions" : [faction],
			"occupying" : Array(),
			"moving" : [unit]
		}
	else:
		var region_details = regions[region]
		if not region_details["moving"].has(unit):
			region_details["moving"].push_back(unit)
			if not region_details["factions"].has(faction):
				region_details["factions"].push_back(faction)
	#print(regions)

func register_unit_position(unit, faction, region):
	if not regions.has(region):
		regions[region] = {
			"factions" : [faction],
			"occupying" : [unit],
			"moving" : Array()
		}
	else:
		var region_details = regions[region]
		if not region_details["occupying"].has(unit):
			region_details["occupying"].push_back(unit)
			if not region_details["factions"].has(faction):
				region_details["factions"].push_back(faction)

func deregister_move(region, faction, unit):
	if regions.has(region):
		if regions[region]["moving"].has(unit):
			regions[region]["moving"].erase(unit)
			if regions[region]["moving"].empty() and regions[region]["occupying"].empty():
				regions.erase(region)

func populate_region_ui(region_name, wealth, region_type):
	$Camera2D/CanvasLayer/RegionPanel.update_panel(region_name, wealth, region_type)

func populate_unit_ui(unit_name, unit_attack, unit_defence, unit_health, unit_color):
	$Camera2D/CanvasLayer/UnitPanel.populate_ui(unit_name, unit_attack, unit_defence, unit_health, unit_color)

func moused_over(object):
	if not moused_elements.empty():
		if moused_elements.back() != selected:
			moused_elements.back().set_deselected()
	if object != selected and not ui_moused_over:
		object.set_selected()
	moused_elements.push_back(object)

func set_ui_moused_over():
	ui_moused_over = true

func set_ui_moused_exit():
	ui_moused_over = false
	select_next()

func mouse_left(object):
	if object != selected and not ui_moused_over:
		object.set_deselected()
	moused_elements.erase(object)
	select_next()

func select_element():
	if not moused_elements.empty():
		var details = null
		var new_selected = selected != moused_elements.back()
		if new_selected:
			reset_selected()
			selected = moused_elements.back()
		if selected:
			details = selected.get_details()
		if details:
			selected.outline_color = Color.yellow
			selected.set_selected()
			match details["type"]:
				"region":
					populate_region_ui(details["name"], details["wealth"], details["region type"])
					selected_type = SELECTED.region
				"unit":
					on_unit_selected()
					populate_unit_ui(details["name"], details["attack"], details["defence"], details["health"], details["color"])
					

func on_unit_selected():
	selected.highlight_paths($LineManager)
	selected_type = SELECTED.unit

func reset_selected():
	if selected:
		selected.set_deselected()
		selected.reset()
		if selected_type == SELECTED.unit and selected.destination == null:
			$LineManager.reset()
		selected_type = null
		selected = null

func get_latest_element():
	return moused_elements.back()

func select_next():
	if not moused_elements.empty():
		moused_elements.back().set_selected()

func register_unit(unit):
	units.push_back(unit)

func execute_commands():
	for unit in units:
		unit.move()

func detect_combat():
	var evaluated_regions = regions.keys()
	for region in evaluated_regions:
		var region_details = regions[region]
		var moving_units = region_details["moving"]
		if moving_units.size() > 1:
			if region_details["factions"].size() > 1:
				var units_by_faction = {}
				var victor = null
				for faction in region_details["factions"]:
					var units = get_units_from_faction(faction, moving_units)
					units_by_faction[faction] = get_combined_stats(units)
					var curr_faction = region_details["factions"][0]
					var stack = units_by_faction[region_details["factions"][0]]
					for other_stack in units_by_faction.values():
						if other_stack != stack:
							var damage = stack["attack"] - other_stack["defence"]
							other_stack["health"] -= damage
							other_stack["damage_taken"] += damage
							damage = other_stack["attack"] - stack["defence"]
							stack["health"] -= damage
							stack["damage_taken"] += damage
							print("stack health: " + str(stack["health"]))
							if other_stack["health"] == 0 and stack["health"] > 0:
								victor = stack
							elif other_stack["health"] > 0 and stack["health"] == 0:
								victor = other_stack
							if victor: 
								break
				for faction in units_by_faction.keys():
					var stack = units_by_faction[faction]
					var units = get_units_from_faction(faction, moving_units)
					print(units)
					var damage = stack["damage_taken"]
					var idx = 0
					print(damage)
					while damage > 0:
						var unit = units[idx]
						var projected_damage = unit.current_health - damage
						if projected_damage <= 0:
							print(unit.name + " is dead!")
							damage -= unit.current_health
						else:
							unit.current_health -= damage
							damage -= unit.current_health

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
	var units = Array()
	for unit in unit_array:
		if unit.faction == faction:
			units.push_back(unit)
	return units

func process_turn():
	disable_ui()
	reset_selected()
	detect_combat()
	execute_commands()
	emit_signal("on_turn_changed")
	select_next()
	regions.clear()

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if Input.is_action_just_pressed('ui_cancel'):
				reset_selected()
				disable_ui()
				select_next()
			elif Input.is_action_just_pressed("ui_select"):
				$Camera2D/CanvasLayer/Popup.set_visible(true)
	if event is InputEventMouseButton:
		if event.pressed:
			if event.is_action_pressed("lmb"):
				if not ui_moused_over:
					select_element()
			if event.is_action_pressed("rmb"):
				if not ui_moused_over:
					if selected_type == SELECTED.unit:
						var element = get_latest_element()
						selected.move_command(element, $LineManager)
