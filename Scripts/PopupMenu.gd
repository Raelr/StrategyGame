extends Menu

func _ready():
	$ConfirmButton.connect("on_press", self, "on_confirm")
	$ExitButton.connect("on_press", self, "on_decline")
	$ConfirmButton.connect("on_hover", self, "on_hover")
	$ExitButton.connect("on_hover", self, "on_hover")
	$ConfirmButton.connect("on_hover_exit", self, "on_hover_exit")
	$ExitButton.connect("on_hover_exit", self, "on_hover_exit")

func on_confirm():
	var world = get_tree().get_root().get_child(0)
	world.process_turn()
	visible = false

func on_decline():
	visible = false

func on_hover():
	pass

func on_hover_exit():
	pass
