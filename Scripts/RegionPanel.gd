extends Menu

export (Array) var region_icons
var is_active = false

signal on_button_close

var types = [
	{
		'name' : 'Grasslands',
		'bonus': 0
	},
	{
		'name': 'Hills',
		'bonus': 1
	}, 
	{
		'name': 'Mountains',
		'bonus' : 2
	}
]

func _ready():
	$RegionPanel/UIButtonIcon.connect("on_hover", self, "on_hover")
	$RegionPanel/UIButtonIcon.connect("on_hover_exit", self, "on_hover_exit")
	$RegionPanel/UIButtonIcon.connect("on_press", self, "deactivate_panel")

func update_panel(regionName, wealth, region_type):
	$RegionPanel/NameText.text = regionName
	$RegionPanel/WealthText.text = str(wealth)
	$RegionPanel/RegionTypeIcon.texture = region_icons[region_type]
	$RegionPanel/RegionTypeIcon/RegionType.text = types[region_type].name
	$RegionPanel/RegionTypeIcon/Effect.text = "+" + str(types[region_type].bonus) + " Defence"
	if not is_active:
		set_visible(true)
		$RegionPanel/AnimationPlayer.play("activated")
		$RegionPanel/AnimationPlayer.queue("idle")
		is_active = true

func deactivate_panel():
	if is_active:
		$RegionPanel/AnimationPlayer.play("deactivated")
		is_active = false
	emit_signal("on_button_close")
