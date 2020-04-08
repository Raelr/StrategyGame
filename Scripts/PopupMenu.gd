extends Menu

func _ready():
	$ConfirmButton.connect("on_press", self, "on_confirm")

func on_confirm():
	print("Confirm Pressed")
