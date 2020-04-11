extends Menu

func _ready():
	$RegionPanel/UIButtonIcon.connect("on_hover", self, "on_hover")
	$RegionPanel/UIButtonIcon.connect("on_hover_exit", self, "on_hover_exit")
