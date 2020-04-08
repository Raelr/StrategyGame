tool
extends Area2D
class_name UIButtonIcon

export (Texture) var button
export (Texture) var icon
export (Color) var buttonColor
export (bool) var update

signal on_press
signal on_hover
signal on_hover_exit

# Register button with popup on_confirm method.
func _ready():
	pass

func _process(delta):
	if update:
		if Engine.editor_hint:
			$ButtonSprite.texture = button
			$ButtonSprite/Icon.texture = icon
			$ButtonSprite.material.set_shader_param("unit_color", buttonColor)

# When the button is pressed, call the signla on the parent. 
func _on_UIButtonIcon_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_just_pressed("lmb"):
				emit_signal("on_press")

func _on_UIButtonIcon_mouse_entered():
	emit_signal("on_hover")
	$ButtonSprite.material.set_shader_param("outline_color", Color.yellow)
	$ButtonSprite/Icon.material.set_shader_param("outline_color", Color.yellow)
	

func _on_UIButtonIcon_mouse_exited():
	emit_signal("on_hover_exit")
	$ButtonSprite.material.set_shader_param("outline_color", Color.black)
	$ButtonSprite/Icon.material.set_shader_param("outline_color", Color.yellow)
