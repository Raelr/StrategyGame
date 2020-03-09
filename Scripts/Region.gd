extends Node2D

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_pressed("lmb"):
				print("CLICKED")
