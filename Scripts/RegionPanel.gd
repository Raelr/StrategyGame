extends Node2D

export (Vector2) var visible_pos
export (Vector2) var invisible_pos
export (float) var duration
var elapsed = 0.0
var move = false
var target_pos

func _ready():
	target_pos = invisible_pos

func update_panel(regionName):
	elapsed = 0.0
	$NameText.text = regionName
	target_pos = visible_pos
	move = visible

func deactivate_panel():
	elapsed = 0.0
	target_pos = invisible_pos
	move = visible

func _process(delta):
	if move:
		if elapsed < duration:
			elapsed += delta
			var fraction = elapsed / duration
			global_position = global_position.linear_interpolate(target_pos, fraction)
		else:
			global_position = target_pos
			move = false
			elapsed = 0.0
			if target_pos == invisible_pos:
				visible = false
