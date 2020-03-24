tool
extends Area2D

export (Color) var unitColor
export (Color) var outline_color
export (bool) var update
var current_region = null

func _process(delta):
	if update:
		if Engine.editor_hint:
			$Unit.material.set_shader_param("unit_color", unitColor)

func set_selected():
	change_outline(Color.yellow)

func set_deselected():
	change_outline(outline_color)

func get_details():
	return {
		"type": "unit"
	}

func reset():
	current_region.reset_neighbours()
	set_deselected()

func change_outline(color):
	$Unit.material.set_shader_param("outline_color", color)

func _on_Area2D_mouse_entered():
	get_parent().moused_over(self)

func _on_Area2D_mouse_exited():
	get_parent().mouse_left(self)

func _on_Unit_area_entered(area):
	current_region = area
