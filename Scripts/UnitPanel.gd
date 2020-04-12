extends Menu

var is_active = false

func _ready():
	$AnchorNode/UnitPanelExitButton.connect("on_hover", self, "on_hover")
	$AnchorNode/UnitPanelExitButton.connect("on_hover_exit", self, "on_hover_exit")
	$AnchorNode/UnitPanelExitButton.connect("on_press", self, "on_close")

func populate_ui(unit_name, unit_attack, unit_defence, unit_health, unit_color):
	$AnchorNode/UnitName.text = unit_name
	$AnchorNode/AttackValue.text = str(unit_attack)
	$AnchorNode/DefenceValue.text = str(unit_defence)
	$AnchorNode/HealthValue.text = str(unit_health["current"]) + "/" + str(unit_health["max"])
	$AnchorNode/HealthBar.max_value = unit_health["max"]
	$AnchorNode/HealthBar.value = unit_health["current"]
	$AnchorNode/UnitIcon.material.set_shader_param("unit_color", unit_color)
	if not is_active:
		set_visible(true)
		$AnchorNode/AnimationPlayer.play("activated")
		is_active = true

func on_close():
	get_tree().get_root().get_child(0).disable_panel(self)

func deactivate_panel():
	var progress = 0.0
	if $AnchorNode/AnimationPlayer.current_animation != "":
		progress = $AnchorNode/AnimationPlayer.current_animation_position 
	if is_active:
		$AnchorNode/AnimationPlayer.current_animation = "deactivated"
		$AnchorNode/AnimationPlayer.seek($AnchorNode/AnimationPlayer.current_animation_length - progress, true)
		$AnchorNode/AnimationPlayer.play()
		is_active = false
