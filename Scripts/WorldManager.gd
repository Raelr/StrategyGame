extends Node2D

func disable_region_ui():
	$Camera2D/RegionPanel.deactivate_panel()

func populate_ui(region_name, wealth, region_type):
	$Camera2D/RegionPanel.update_panel(region_name, wealth, region_type)
	
