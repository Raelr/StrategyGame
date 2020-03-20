extends Node2D

func disable_region_ui():
	$Camera2D/RegionPanel.deactivate_panel()

func populate_ui(region_name, wealth, region_type):
	$Camera2D/RegionPanel.update_panel(region_name, wealth, region_type)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if Input.is_action_just_pressed('ui_cancel'):
				disable_region_ui()
