extends Node2D

enum SELECTED {region, unit}
var moused_elements = Array()
var selected = null
var selected_type
var ui_moused_over = false

signal on_turn_changed

var units = Array()

func _ready():
	$Camera2D/CanvasLayer/Popup.connect("on_button_mouseover", self, "set_ui_moused_over")
	$Camera2D/CanvasLayer/Popup.connect("on_button_exit", self, "set_ui_moused_exit")
	$Camera2D/CanvasLayer/Control.connect("on_button_mouseover", self, "set_ui_moused_over")
	$Camera2D/CanvasLayer/Control.connect("on_button_exit", self, "set_ui_moused_exit")

func disable_region_ui():
	#$Camera2D/CanvasLayer/RegionPanel.deactivate_panel()
	if selected_type == SELECTED.region:
		reset_selected()
	pass

func populate_ui(region_name, wealth, region_type):
	pass
	#$Camera2D/CanvasLayer/RegionPanel.update_panel(region_name, wealth, region_type)

func moused_over(object):
	if not ui_moused_over:
		if not moused_elements.empty():
			if moused_elements.back() != selected:
				moused_elements.back().set_deselected()
		if object != selected:
			object.set_selected()
		moused_elements.push_back(object)

func set_ui_moused_over():
	ui_moused_over = true

func set_ui_moused_exit():
	ui_moused_over = false
	select_next()

func mouse_left(object):
	if not ui_moused_over:
		if object != selected:
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
					populate_ui(details["name"], details["wealth"], details["region type"])
					selected_type = SELECTED.region
				"unit":
					on_unit_selected()

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

func process_turn():
	reset_selected()
	execute_commands()
	emit_signal("on_turn_changed")

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if Input.is_action_just_pressed('ui_cancel'):
				reset_selected()
				disable_region_ui()
				select_next()
			elif Input.is_action_just_pressed("ui_select"):
				$Camera2D/CanvasLayer/Popup.set_enabled(true)
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
