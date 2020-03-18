extends Node2D

var is_activated = false

func update_panel(regionName, wealth):
	$RegionPanel/NameText.text = regionName
	$RegionPanel/WealthText.text = str(wealth)
	if not is_activated:
		set_visible(true)
		$RegionPanel/AnimationPlayer.current_animation = "activated"
		$RegionPanel/AnimationPlayer.queue("idle")
		$RegionPanel/AnimationPlayer.play()
		$RegionPanel/Button.reset()
		is_activated = true

func deactivate_panel():
	$RegionPanel/AnimationPlayer.current_animation = "deactivated"
	$RegionPanel/AnimationPlayer.play()
	is_activated = false

func set_visible(state):
	visible = state
