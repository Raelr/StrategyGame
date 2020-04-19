extends Menu

func _ready():
	$ConfirmButton.connect("on_press", self, "on_confirm")
	$ExitButton.connect("on_press", self, "on_decline")
	$ConfirmButton.connect("on_hover", self, "on_hover")
	$ExitButton.connect("on_hover", self, "on_hover")
	$ConfirmButton.connect("on_hover_exit", self, "on_hover_exit")
	$ExitButton.connect("on_hover_exit", self, "on_hover_exit")
	connect("on_menu_status_change", $ExitButton, "on_button_status_change")
	connect("on_menu_status_change", $ConfirmButton, "on_button_status_change")
	set_visible(false)

func on_confirm():
	var world = get_tree().get_root().get_child(0)
	world.process_turn()
	set_visible(false)
	set_process(false)

func on_decline():
	set_visible(false)
	set_process(false)
