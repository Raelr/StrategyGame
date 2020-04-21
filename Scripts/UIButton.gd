tool
extends Area2D
class_name UIButtonIcon

const enums = preload('res://Scripts/FactionData.gd')

export (Texture) var button
export (Texture) var icon
export (Color) var buttonColor
export (Color) var outline_idle
export (Color) var outline_active
export (Color) var icon_idle
export (bool) var show_icon_outline
export (bool) var change_icon_color
export (bool) var update

var type = enums.SELECTION_TYPE.ui

signal on_press
signal on_hover(button)
signal on_hover_exit(button)

# Register button with popup on_confirm method.
func _ready():
	var world = get_tree().get_root().get_child(0)
	connect("on_hover", world, "moused_over")
	connect("on_hover_exit", world, "mouse_left")

func _process(delta):
	if update:
		if Engine.editor_hint:
			$ButtonSprite.texture = button
			$ButtonSprite/Icon.texture = icon
			$ButtonSprite.material.set_shader_param("unit_color", buttonColor)
			$ButtonSprite.material.set_shader_param("outline_color", outline_idle)
			if not show_icon_outline:
				$ButtonSprite/Icon.material.set_shader_param("width", 0)

func get_type():
	return type

# When the button is pressed, call the signla on the parent. 
func _on_UIButtonIcon_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_just_pressed("lmb"):
				emit_signal("on_press")

func _on_UIButtonIcon_mouse_entered():
	emit_signal("on_hover", self)
	$ButtonSprite.material.set_shader_param("outline_color", outline_active)
	if show_icon_outline:
		$ButtonSprite/Icon.material.set_shader_param("outline_color", outline_active)
	if change_icon_color:
		$ButtonSprite/Icon.material.set_shader_param("unit_color", outline_active)

func _on_UIButtonIcon_mouse_exited():
	emit_signal("on_hover_exit", self)
	$ButtonSprite.material.set_shader_param("outline_color", outline_idle)
	if show_icon_outline:
		$ButtonSprite/Icon.material.set_shader_param("outline_color", outline_idle)
	if change_icon_color:
		$ButtonSprite/Icon.material.set_shader_param("unit_color", icon_idle)

func on_button_status_change(status):
	monitoring = status
	monitorable = status
