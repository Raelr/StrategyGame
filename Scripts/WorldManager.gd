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
	if not moused_elements.empty(): 
		moused_elements.back().set_selected()

func select_element():
	if not moused_elements.empty():
		selected = moused_elements.back()
		var details = selected.get_details()
		if details["type"] == "region":
			populate_ui(details["name"], details["wealth"], details["region type"])
		elif details["type"] == "unit":
			pass

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if Input.is_action_just_pressed('ui_cancel'):
				disable_region_ui()
	if event is InputEventMouseButton:
		if event.pressed:
			if event.is_action_pressed("lmb"):
				select_element()
			
