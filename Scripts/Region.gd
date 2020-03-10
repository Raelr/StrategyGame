tool
extends Node2D
export (Texture) var region_details
export (Texture) var region_outline
export (Texture) var region_overlay
export (bool) var ui_update
export (Color) var occupied_color
export (float) var change_duration
var elapsed = 0.0

func _ready():
	change_region_sprite()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			ui_update = true
			if Input.is_action_pressed("lmb"):
				occupied_color = Color(1, 0, 0, 0.4)
			elif Input.is_action_pressed("rmb"):
				occupied_color = Color(0, 0, 0, 0)

func _process(delta):
	if ui_update:
		if Engine.editor_hint:
			change_region_sprite()
			set_occupied(occupied_color)
		transition_color(delta, occupied_color)

func change_region_sprite():
	$Details.texture = region_details
	$Details/Outline.texture = region_outline
	$Details/Overlay.texture = region_overlay

func transition_color(delta, color):
	if elapsed < change_duration:
		elapsed += delta
		set_occupied($Details/Overlay.modulate.linear_interpolate(color, delta * 5))
	elif elapsed >= change_duration:
		set_occupied(color)
		elapsed = 0.0
		ui_update = false

func set_occupied(color): 
	$Details/Overlay.modulate = color
	$Details/Outline.modulate = Color(color.r,color.g,color.b, 1)
