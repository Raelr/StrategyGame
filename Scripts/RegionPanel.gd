extends Menu

export (Array) var region_icons
var is_active = false

signal on_button_close

func _ready():
	$RegionPanel/UIButtonIcon.connect("on_hover", self, "on_hover")
	$RegionPanel/UIButtonIcon.connect("on_hover_exit", self, "on_hover_exit")
	$RegionPanel/UIButtonIcon.connect("on_press", self, "on_close")

func update_panel(regionName, wealth, region_type):
	$RegionPanel/NameText.text = regionName
	$RegionPanel/WealthText.text = str(wealth)
	$RegionPanel/RegionTypeIcon.texture = region_icons[region_type.idx]
	$RegionPanel/RegionTypeIcon/RegionType.text = region_type.name
	$RegionPanel/RegionTypeIcon/Effect.text = "+" + str(region_type.bonus) + " Defence"
	if not is_active:
		set_visible(true)
		$RegionPanel/AnimationPlayer.play("activated")
		$RegionPanel/AnimationPlayer.queue("idle")
		is_active = true

func on_close():
	get_tree().get_root().get_child(0).disable_panel(self)

func deactivate_panel():
	if is_active:
		$RegionPanel/AnimationPlayer.play("deactivated")
		is_active = false
	emit_signal("on_button_close")
