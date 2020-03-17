extends Node2D

func disable_region_ui():
	$CanvasLayer/RegionPanel.deactivate_panel()

func populate_ui(region_name, wealth):
	$CanvasLayer/RegionPanel.update_panel(region_name, wealth)
	
