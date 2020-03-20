extends Node2D

var is_activated = false

export (Array) var region_icons

var types = [
	{
		'name': 'Grasslands',
		'bonus': 0
	},
	{
		'name': 'Hills',
		'bonus': 1
	},
	{
		'name': 'Mountains',
		'bonus': 2
	}
]

func update_panel(regionName, wealth, region_type):
	$RegionPanel/NameText.text = regionName
	$RegionPanel/WealthText.text = str(wealth)
	$RegionPanel/RegionTypeIcon.texture = region_icons[region_type]
	$RegionPanel/RegionTypeIcon/RegionType.text = types[region_type].name
	$RegionPanel/RegionTypeIcon/Effect.text = "+" + str(types[region_type].bonus) + " Defence"
	if not is_activated:
		set_visible(true)
		$RegionPanel/AnimationPlayer.current_animation = "activated"
		$RegionPanel/AnimationPlayer.queue("idle")
		$RegionPanel/AnimationPlayer.play()
		$RegionPanel/Button.reset()
		is_activated = true

func deactivate_panel():
	if is_activated:
		$RegionPanel/AnimationPlayer.current_animation = "deactivated"
		$RegionPanel/AnimationPlayer.play()
		is_activated = false

func set_visible(state):
	visible = state
