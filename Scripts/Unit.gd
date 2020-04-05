tool
extends Area2D

export (Color) var unitColor
export (Color) var outline_color
export (Color) var faction_color
export (bool) var update
export (float) var move_speed
var current_region = null
var destination = null
var elapsed = 0.0
var line_manager = null

func _ready():
	$Unit.material.set_shader_param("unit_color", faction_color)
	$Unit/AnimationPlayer.play("idle")
	get_parent().register_unit(self)

func _process(delta):
	if update:
		if Engine.editor_hint:
			$Unit.material.set_shader_param("unit_color", unitColor)
		if destination:
			if elapsed < move_speed:
				elapsed += delta
				var fraction = elapsed / move_speed
				position = position.linear_interpolate(destination.position, fraction)
				if fraction >= 0.4 and fraction < 0.45:
					position = destination.position
					set_current_region(destination)
			elif elapsed >= move_speed:
				elapsed = 0.0
				destination = null
				update = false

func set_selected():
	change_outline(Color.yellow)
	if not $Unit/AnimationPlayer.current_animation == "salute" and not $Unit/AnimationPlayer.current_animation == "":
		$Unit/AnimationPlayer.play("salute")

func set_deselected():
	change_outline(Color.black)
	$Unit/AnimationPlayer.play("desalute")
	$Unit/AnimationPlayer.queue("idle")

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

func move():
	if destination:
		if line_manager:
			line_manager.reset()
		update = true

func set_current_region(region):
	current_region = region
	current_region.on_new_occupant(faction_color)
	if line_manager:
		line_manager.reset()

func move_command(moused_element, line_manager):
	var n = get_possible_paths()
	for region in n:
		if region == moused_element:
			line_manager.reset()
			self.line_manager = line_manager
			line_manager.draw_single_line(position, region)
			destination = region
			break

func get_possible_paths():
	return current_region.get_neighbours()

func highlight_paths(line_manager):
	line_manager.draw_lines(position, get_possible_paths())
