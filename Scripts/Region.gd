tool
extends Node2D

enum REGIONTYPE { grassLand, hills, mountains }

# Configuration Variables
export (Texture) var region_details
export (Texture) var region_outline
export (Texture) var region_overlay
export (bool) var update
export (Color) var occupied_color
export (float) var change_duration
export (REGIONTYPE) var region_type

# Region Variables
export (String) var region_name
export (int) var wealth

onready var outline_color = Color(0,0,0,1)
var elapsed = 0.0

func _ready():
	change_region_sprite()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_pressed("lmb"):
				get_parent().populate_ui(region_name, wealth, region_type)

func _process(delta):
	if update:
		if Engine.editor_hint:
			change_region_sprite()
		set_occupied(occupied_color, outline_color, delta)

func change_region_sprite():
	$Details.texture = region_details
	$Details/Outline.texture = region_outline
	$Details/Overlay.texture = region_overlay

func set_occupied(overlay_color, border_color, delta): 
	transition_color(delta, $Details/Overlay, occupied_color)
	$Details/Outline.modulate = border_color

func transition_color(delta, ui, dest_color):
	if elapsed < change_duration:
		elapsed += delta
		ui.modulate = ui.modulate.linear_interpolate(dest_color, elapsed / change_duration)
	elif elapsed >= change_duration:
		ui.modulate = dest_color
		elapsed = 0.0
		update = false

func change_outline(color):
	outline_color = color
	elapsed = 0.0
	update = true

func _on_Area2D_mouse_entered():
	change_outline(Color(1, 1, 0, 1))

func _on_Area2D_mouse_exited():
	change_outline(Color(occupied_color.r, occupied_color.g, occupied_color.b, 1))
