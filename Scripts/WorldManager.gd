extends Node2D

func disable_region_ui():
	$RegionPanel.deactivate_panel()

func populate_ui(region_name, wealth):
	$RegionPanel.update_panel(region_name, wealth)
	
