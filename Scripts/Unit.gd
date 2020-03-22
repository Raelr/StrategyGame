tool
extends Area2D

export (Color) var unitColor
export (bool) var update

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_pressed("lmb"):
				pass

func _process(delta):
	if update:
		if Engine.editor_hint:
			$Unit.material.set_shader_param("sprite_unit_color", unitColor)

func _on_Area2D_mouse_entered():
	$Unit.material.set_shader_param("outline_color", Color.yellow)


func _on_Area2D_mouse_exited():
	$Unit.material.set_shader_param("outline_color", Color.black)
