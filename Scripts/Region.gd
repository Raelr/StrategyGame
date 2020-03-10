tool
extends Node2D
export (Texture) var region_details
export (Texture) var region_outline
export (Texture) var region_overlay
export (bool) var editor_update
export (Color) var occupied_color
export (float) var change_duration
var outline_color = Color(0,0,0,1)
var elapsed = 0.0
var has_changed = false

func _ready():
	change_region_sprite()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			has_changed = true
			elapsed = 0.0
			if Input.is_action_pressed("lmb"):
				occupied_color = Color(1, 0, 0, 0.4)
				outline_color = Color(1, 0, 0, 1)
			elif Input.is_action_pressed("rmb"):
				occupied_color = Color(0, 0, 0, 0)
				outline_color = Color(0, 0, 0, 1)

func _process(delta):
	if editor_update:
		if Engine.editor_hint:
			change_region_sprite()
			set_occupied(occupied_color, Color(occupied_color.r,occupied_color.g,occupied_color.b, 1), delta)

	if has_changed:
		set_occupied(occupied_color, outline_color, delta)

func change_region_sprite():
	$Details.texture = region_details
	$Details/Outline.texture = region_outline
	$Details/Overlay.texture = region_overlay

func set_occupied(overlay_color, border_color, delta): 
	transition_color(delta, $Details/Overlay, occupied_color)
	transition_color(delta, $Details/Outline, border_color)

func transition_color(delta, ui, dest_color):
	if elapsed < change_duration:
		elapsed += delta
		ui.modulate = ui.modulate.linear_interpolate(dest_color, elapsed / change_duration)
	elif elapsed >= change_duration:
		ui.modulate = dest_color
		elapsed = 0.0
		has_changed = false

func change_outline(color):
	outline_color = color
	elapsed = 0.0
	has_changed = true

func _on_Area2D_mouse_entered():
	change_outline(Color(1, 1, 0, 1))

func _on_Area2D_mouse_exited():
	change_outline(Color(occupied_color.r, occupied_color.g, occupied_color.b, 1))
