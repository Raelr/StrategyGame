tool
extends Node2D

enum REGIONTYPE { grassLand, hills, mountains }

# Configuration Variables
export (Texture) var region_details
export (Texture) var region_overlay
export (bool) var update = false
export (Color) var occupied_color
export (float) var change_duration
export (REGIONTYPE) var region_type
export (Array) var neighbours
# Region Variables
export (String) var region_name
export (int) var wealth

onready var outline_color = Color(0,0,0,1)
var elapsed = 0.0

func _ready():
	change_region_sprite()

func get_details():
	return {
		"type": "region",
		"name": region_name,
		"wealth": wealth,
		"region type": region_type
	}

func _process(delta):
	if update:
		if Engine.editor_hint:
			change_region_sprite()
		set_occupied(occupied_color, outline_color, delta)

func change_region_sprite():
	$Details.texture = region_details
	$Details/Overlay.texture = region_overlay

func set_occupied(overlay_color, border_color, delta): 
	transition_color(delta, $Details/Overlay, occupied_color)

func transition_color(delta, ui, dest_color):
	var overlay = Color(dest_color.r, dest_color.g, dest_color.b ,0.5)
	if elapsed < change_duration:
		elapsed += delta
		ui.modulate = ui.modulate.linear_interpolate(overlay, elapsed / change_duration)
		change_outline($Details.material.get_shader_param("outline_color").linear_interpolate(dest_color, elapsed / change_duration))
	elif elapsed >= change_duration:
		ui.modulate = overlay
		elapsed = 0.0
		update = false

func change_outline(color):
	$Details.material.set_shader_param("outline_color", color)

func set_selected():
	change_outline(Color.yellow)

func set_deselected():
	change_outline(outline_color)

func reset():
	set_deselected()

func _on_Area2D_mouse_entered():
	get_parent().moused_over(self)

func _on_Area2D_mouse_exited():
	get_parent().mouse_left(self)

func show_neighbours(unit_neighbours):
	for neighbour in unit_neighbours:
		neighbour.outline_color = Color.white
		neighbour.change_outline(neighbour.outline_color)

func get_neighbours():
	var n = Array()
	for neighbour in neighbours:
		n.push_back(get_node(neighbour))
	return n

func reset_neighbours():
	for neighbour in neighbours:
		var n = get_node(neighbour)
		n.outline_color = n.occupied_color
		n.change_outline(n.outline_color)
