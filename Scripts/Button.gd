tool
extends Node2D

export (Color) var border_idle
export (Color) var fill_idle
export (Color) var border_hover
export (Color) var fill_hover
export (Color) var border_click
export (Color) var fill_click

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_pressed("lmb"):
				get_parent().get_parent().deactivate_panel()

func on_mouse_exit():
	pass


func on_hover():
	print("MOUSE")
	$ButtonOutline.modulate = fill_hover
	$ButtonBorder.modulate = border_hover
