tool
extends Area2D

export (Color) var unitColor
export (Color) var outline_color
export (Color) var faction_color
export (bool) var update
export (float) var move_speed

export (int) var defence
export (int) var attack
export (int) var max_health
export (int) var current_health
export (String) var unit_name

var current_region = null
var destination = null
var elapsed = 0.0
var line_manager = null
var path = null

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
		"type": "unit",
		"name": unit_name,
		"attack": attack,
		"defence": defence,
		"health" : {
			"current" : current_health,
			"max" : max_health
		},
		"color" : faction_color
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
		if path:
			path.queue_free()
			path = null
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
			if region == destination:
				return
			else:
				if path:
					path.queue_free()
					path = null
			if not path:
				line_manager.draw_single_line(position, moused_element, Color.white)
			path = line_manager.select_arrow(moused_element.region_name)
			if path:
				add_child(path)
			self.line_manager = line_manager
			destination = region
			break

func get_possible_paths():
	return current_region.get_neighbours()

func highlight_paths(line_manager):
	destination = null
	if path:
		path.queue_free()
		path = null
	line_manager.draw_lines(position, get_possible_paths())
