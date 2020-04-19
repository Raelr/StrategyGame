extends Node2D

enum SELECTED {region, unit}
enum FACTIONS {player, neutral}
var moused_elements = Array()
var selected = null
var selected_type
var ui_moused_over = false
var turn_over = false

signal on_turn_changed
signal on_turn_ended

var types = [
	{
		'idx' : 0,
		'name' : 'Grasslands',
		'bonus': 0
	},
	{
		'idx' : 1,
		'name': 'Hills',
		'bonus': 1
	}, 
	{
		'idx' : 2,
		'name': 'Mountains',
		'bonus' : 2
	}
]

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
	#print("Registering unit: " + unit.name + " of faction: " + str(faction) + " in region: " + region.region_name)
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
		regions[region] = region_details
	#print(region.region_name + " is now being occupied by: " + str(regions[region]["occupying"]))

func deregister_move(region, unit):
	if regions.has(region):
		if regions[region]["moving"].has(unit):
			regions[region]["moving"].erase(unit)
			if regions[region]["moving"].empty() and regions[region]["occupying"].empty():
				regions.erase(region)

func populate_region_ui(region_name, wealth, region_type):
	$Camera2D/CanvasLayer/RegionPanel.update_panel(region_name, wealth, types[region_type])

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
	selected.reset_move()
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

func process_turn():
	var command_manager = $CommandManager
	turn_over = true
	emit_signal("on_turn_changed")
	disable_ui()
	command_manager.process_command(regions, types)
	yield($CommandManager,"combat_ended")
	select_next()
	regions.clear()
	emit_signal("on_turn_ended")
	turn_over = false

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
			if event.is_action_pressed("rmb") and not turn_over:
				if not ui_moused_over:
					if selected_type == SELECTED.unit:
						var element = get_latest_element()
						selected.move_command(element, $LineManager)
