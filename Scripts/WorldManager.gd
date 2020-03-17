extends Node2D

func set_ui_state(state):
	$RegionPanel.visible = state

func disable_region_ui():
	$RegionPanel.deactivate_panel()

func populate_ui(region_name):
	set_ui_state(true)
	$RegionPanel.update_panel(region_name)
	
