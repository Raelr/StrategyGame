tool
extends Area2D

export (Color) var unitColor
export (Color) var outline_color
export (Color) var faction_color
export (bool) var update
var current_region = null

func _process(delta):
	if update:
		if Engine.editor_hint:
			$Unit.material.set_shader_param("unit_color", unitColor)

func set_selected():
	change_outline(Color.yellow)

func set_deselected():
	change_outline(Color.black)

func get_details():
	return {
		"type": "unit"
	}

func reset():
	set_deselected()

func change_outline(color):
	$Unit.material.set_shader_param("outline_color", color)

func _on_Area2D_mouse_entered():
	get_parent().moused_over(self)

func _on_Area2D_mouse_exited():
	get_parent().mouse_left(self)

func _on_Unit_area_entered(area):
	if not current_region:
		set_current_region(area)

func move_unit(region):
	position = region.position
	set_current_region(region)

func set_current_region(region):
	current_region = region
	current_region.on_new_occupant(faction_color)

func process_action(moused_element, line_manager):
	var n = get_possible_paths()
	for region in n:
		if region == moused_element:
			line_manager.reset()
			move_unit(moused_element)
			highlight_paths(line_manager)
			break

func get_possible_paths():
	return current_region.get_neighbours()

func highlight_paths(line_manager):
	line_manager.draw_lines(position, get_possible_paths())
