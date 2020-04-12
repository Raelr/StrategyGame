extends Menu

var is_active = false

func populate_ui(unit_name, unit_attack, unit_defence, unit_health, unit_color):
	$AnchorNode/UnitName.text = unit_name
	$AnchorNode/AttackValue.text = str(unit_attack)
	$AnchorNode/DefenceValue.text = str(unit_defence)
	$AnchorNode/HealthValue.text = str(unit_health["current"])
	$AnchorNode/HealthBar.max_value = unit_health["max"]
	$AnchorNode/HealthBar.value = unit_health["current"]
	$AnchorNode/UnitIcon.material.set_shader_param("unit_color", unit_color)
	if not is_active:
		visible = true
		$AnchorNode/AnimationPlayer.play("activated")

