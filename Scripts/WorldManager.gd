extends Node2D

var moused_elements = Array()
var selected = null

func disable_region_ui():
	$Camera2D/CanvasLayer/RegionPanel.deactivate_panel()

func populate_ui(region_name, wealth, region_type):
	$Camera2D/CanvasLayer/RegionPanel.update_panel(region_name, wealth, region_type)

func moused_over(object):
	if not moused_elements.empty():
		moused_elements.back().set_deselected()
	object.set_selected()
	moused_elements.push_back(object)

func mouse_left(object):
	object.set_deselected()
	moused_elements.erase(object)
	select_last_object()

func select_element():
	if not moused_elements.empty():
		var details = null
		if selected != moused_elements.back():
			reset_selected(selected)
			selected = moused_elements.back()
		if selected:
			details = selected.get_details()
		if details:
			selected.outline_color = Color.yellow
			selected.set_selected()
			match details["type"]:
				"region":
					populate_ui(details["name"], details["wealth"], details["region type"])
				"unit":
					show_unit_paths(selected)

func show_unit_paths(unit):
	var unit_region = unit.current_region
	unit_region.show_neighbours()

func reset_selected(selected_item):
	if selected:
		selected_item.outline_color = Color.black
		selected_item.reset()

func select_last_object():
	if not moused_elements.empty():
		moused_elements.back().set_selected()

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if Input.is_action_just_pressed('ui_cancel'):
				reset_selected(selected)
				disable_region_ui()
				select_last_object()
	if event is InputEventMouseButton:
		if event.pressed:
			if event.is_action_pressed("lmb"):
				select_element()
			
