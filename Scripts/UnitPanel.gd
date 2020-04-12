extends Menu

func populate_ui(unit_name, unit_attack, unit_defence, unit_health, unit_color):
	$UnitName.text = unit_name
	$AttackValue.text = str(unit_attack)
	$DefenceValue.text = str(unit_defence)
	$HealthValue.text = str(unit_health["current"])
	$HealthBar.max_value = unit_health["max"]
	$HealthBar.value = unit_health["current"]
	$UnitIcon.material.set_shader_param("unit_color", unit_color)
