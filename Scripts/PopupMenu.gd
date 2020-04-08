extends Menu

signal on_button_mouseover
signal on_button_exit

func _ready():
	$ConfirmButton.connect("on_press", self, "on_confirm")
	$ExitButton.connect("on_press", self, "on_decline")
	$ConfirmButton.connect("on_hover", self, "on_hover")
	$ExitButton.connect("on_hover", self, "on_hover")
	$ConfirmButton.connect("on_hover_exit", self, "on_hover_exit")
	$ExitButton.connect("on_hover_exit", self, "on_hover_exit")

func set_enabled(status):
	visible = status

func on_confirm():
	var world = get_tree().get_root().get_child(0)
	world.process_turn()
	set_enabled(false)
	set_process(false)

func on_decline():
	set_enabled(false)
	set_process(false)

func on_hover():
	emit_signal("on_button_mouseover")

func on_hover_exit():
	emit_signal("on_button_exit")
