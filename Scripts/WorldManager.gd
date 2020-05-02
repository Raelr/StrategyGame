extends Node2D

# KNOWN BUGS:
# 1. Units are moving BETWEEN different regions instead of only moving to a single region. 

enum FACTIONS {player, neutral}
var moused_elements = Array()
var moused_units = Array()
var moused_ui = Array()
var selected = null
var selected_type
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

func _ready():
	$Camera2D/CanvasLayer/UnitPanel.connect("on_button_close", self, "disable_region_ui")

func disable_ui():
	$Camera2D/CanvasLayer/UnitPanel.deactivate_panel()
	$Camera2D/CanvasLayer/RegionPanel.deactivate_panel()
	reset_selected()

func disable_panel(panel):
	panel.deactivate_panel()
	reset_selected()

# TODO: Add ability to modify command abilities based on given commands. 
# I.e: A unit moving from one location to another is no longer 'occupying the original location'
func register_move_command(region, unit):
	$WorldStateManager.add_standard_move_command(unit, region)

func erase_occupation(region):
	$WorldStateManager.erase_occupation(region)

func register_unit_position(unit, region, faction):
	$WorldStateManager.add_occupying_unit(unit, region.region_name, faction)

func populate_region_ui(region_name, wealth, region_type):
	$Camera2D/CanvasLayer/RegionPanel.update_panel(region_name, wealth, types[region_type])

func populate_unit_ui(unit_name, unit_attack, unit_defence, unit_health, unit_color):
	$Camera2D/CanvasLayer/UnitPanel.populate_ui(unit_name, unit_attack, unit_defence, unit_health, unit_color)

func moused_over(object, type):
	var container = get_container_by_type(type) 
	if not container.empty():
		if container.back() != selected:
			container.back().set_deselected()
	container.push_back(object)
	select_latest()

func get_container_by_type(type):
	var container = Array()
	match type:
		0:
			container = moused_units
		1: 
			container = moused_elements
		2: 
			container = moused_ui
	return container

func select_latest():
	var element = get_latest()
	if element:
		element.set_selected()

func get_latest():
	var element = null
	if not moused_ui.empty():
		element = moused_ui.back()
		deselect_all(moused_units)
		deselect_all(moused_elements)
	elif not moused_units.empty():
			element = moused_units.back()
			deselect_all(moused_elements)
	elif not moused_elements.empty():
			element = moused_elements.back()
	return element

func mouse_left(object, type):
	var container = get_container_by_type(type) 
	if object != selected:
		object.set_deselected()
	container.erase(object)
	select_latest()

func select_element():
	var element = get_latest()
	if element:
		var details = null
		var new_selected = selected != element
		if new_selected:
			reset_selected()
			selected = element
			selected.set_selected()
			var type = selected.get_type()
			if type == 0 || type == 1:
				details = selected.get_details()
			match type:
				0:
					#Need to find a way to get paths to render even if unit is selected
					selected.reset_move()
					selected.highlight_paths($LineManager)
					selected_type = type
					populate_unit_ui(details["name"], details["attack"], details["defence"], details["health"], details["color"])
				1:
					populate_region_ui(details["name"], details["wealth"], details["region type"])
					selected_type = type
				2:
					selected.on_press()
					selected_type = type

func deselect_all(container):
	for element in container:
		element.set_deselected()

func reset_selected():
	if selected:
		selected.set_deselected()
		if selected_type == 0 and selected.destination == null:
			$LineManager.reset()
		selected_type = null
		selected = null

func process_turn():
	turn_over = true
	emit_signal("on_turn_changed")
	disable_ui()
	$WorldStateManager.process_turn_sequence(types)
	yield($WorldStateManager,"turn_ended")
	$WorldStateManager.reset_commands()
	select_latest()
	turn_over = false
	emit_signal("on_turn_ended")

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if Input.is_action_just_pressed('ui_cancel'):
				reset_selected()
				disable_ui()
				select_latest()
			elif Input.is_action_just_pressed("ui_select"):
				$Camera2D/CanvasLayer/Popup.set_visible(true)
	if event is InputEventMouseButton:
		if event.pressed:
			if event.is_action_pressed("lmb"):
					select_element()
			if event.is_action_pressed("rmb") and not turn_over:
					if selected_type == 0:
						var element = get_latest()
						selected.move_command(element, $LineManager)
