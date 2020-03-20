extends Camera2D

onready var screen = get_viewport().size

func _process(delta):
	if (get_viewport().get_mouse_position().x > screen.x) or get_viewport().get_mouse_position().x < 0:
		pass
