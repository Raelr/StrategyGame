extends Node2D

var selected_element = null
var moused_elements = Array()

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

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if Input.is_action_just_pressed('ui_cancel'):
				disable_region_ui()
