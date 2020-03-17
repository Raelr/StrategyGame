extends Node2D

func set_ui_state(state):
	$RegionPanel.visible = state

func populate_ui(region_name):
	$RegionPanel.update_panel(region_name)
	set_ui_state(true)
