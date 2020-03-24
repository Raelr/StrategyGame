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
	if elapsed < change_duration:
		elapsed += delta
		ui.modulate = ui.modulate.linear_interpolate(dest_color, elapsed / change_duration)
	elif elapsed >= change_duration:
		ui.modulate = dest_color
		elapsed = 0.0
		update = false

func change_outline(color):
	$Details.material.set_shader_param("outline_color", color)
	elapsed = 0.0
	update = true

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

func show_neighbours():
	for neighbour in neighbours:
		var n = get_node(neighbour)
		n.outline_color = Color.white
		n.change_outline(n.outline_color)

func reset_neighbours():
	for neighbour in neighbours:
		var n = get_node(neighbour)
		n.outline_color = Color.black
		n.change_outline(n.outline_color)
