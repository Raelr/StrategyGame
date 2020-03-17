extends Node2D

export (Vector2) var visible_pos

func update_panel(regionName):
	$NameText.text = regionName
