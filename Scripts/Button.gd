extends Node2D

export (Color) var border_idle
export (Color) var fill_idle
export (Color) var border_hover
export (Color) var fill_hover
export (Color) var border_click
export (Color) var fill_click

var retracting = false

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_just_pressed("lmb"):
				retracting = true
				set_color(fill_click, border_click)
				get_parent().get_parent().deactivate_panel()

func on_mouse_exit():
	if not retracting:
		set_color(fill_idle, border_idle)

func reset():
	retracting = false
	set_color(fill_idle, border_idle)

func on_hover():
	if not retracting:
		set_color(fill_hover, border_hover)

func set_color(fill, border):
	$ButtonOutline.modulate = fill
	$ButtonBorder.modulate = border
