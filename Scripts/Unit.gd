tool
extends Selectable

# TODO: Strip this class of specific functionality and make it more generic for reuse. 
# Possibly make it a class_name so that it can be used by multiple units. 

export (enums.FACTION) var faction
export (Color) var unitColor
export (Color) var faction_color
export (float) var move_speed

export (int) var defence
export (int) var attack
export (int) var max_health
export (int) var current_health
export (int) var speed
export (String) var unit_name
export (NodePath) var start_region

var current_region = null
var destination = null
var elapsed = 0.0
var line_manager = null
var path = null
var is_dead = false

signal on_move_command(region, faction, unit)
signal finished_move

func _ready():
	set_selection_type(enums.SELECTION_TYPE.unit)
	on_ready()
	$Unit.material.set_shader_param("unit_color", faction_color)
	$Unit/AnimationPlayer.play("idle")
	var world = get_tree().get_root().get_child(0)
	world.connect("on_turn_ended", self, "register_position")
	$UnitHealth.max_value = max_health
	$UnitHealth.value = current_health
	set_current_region(get_node(start_region))

func get_type():
	return selection_type

func _process(delta):
	if update:
		if Engine.editor_hint:
			$Unit.material.set_shader_param("unit_color", unitColor)
		if destination:
			if elapsed < move_speed:
				elapsed += delta
				var fraction = elapsed / move_speed
				position = position.linear_interpolate(destination.position, fraction)
				if fraction >= 0.4 and fraction < 0.45:
					position = destination.position
					set_current_region(destination)
			elif elapsed >= move_speed:
				elapsed = 0.0
				destination = null
				update = false

func set_selected():
	.set_selected()
	if not $Unit/AnimationPlayer.current_animation == "salute" and not $Unit/AnimationPlayer.current_animation == "":
		$Unit/AnimationPlayer.play("salute")

func set_deselected():
	.set_deselected()
	$Unit/AnimationPlayer.play("desalute")
	$Unit/AnimationPlayer.queue("idle")

func get_details():
	return {
		"name": unit_name,
		"attack": attack,
		"defence": defence,
		"health" : {
			"current" : current_health,
			"max" : max_health
		},
		"color" : faction_color
	}

func reset_move():
	var neighbours = get_possible_paths()
	register_position()

func _on_Area2D_mouse_entered():
	emit_signal("on_hover", self, get_type())

func _on_Area2D_mouse_exited():
	emit_signal("on_hover_exit", self, get_type())

func move(dest):
	destination = dest
	if line_manager:
		line_manager.reset()
	if path:
		path.queue_free()
		path = null
	update = true

func set_current_region(region):
	current_region = region
	current_region.on_new_occupant(faction_color)
	if line_manager:
		line_manager.reset()
	register_position()
	emit_signal("finished_move")

func move_command(moused_element, line_manager):
	var n = get_possible_paths()
	if not (moused_element == current_region):
		for region in n:
			if region == moused_element:
				if region == destination:
					return
				else:
					if path:
						path.queue_free()
						path = null
				if not path:
					line_manager.draw_single_line(position, moused_element, Color.white)
				path = line_manager.select_arrow(moused_element.region_name)
				if path:
					add_child(path)
				self.line_manager = line_manager
				get_parent().register_move_command(region, self)
				break
	else:
		register_position()

func register_position():
	if not is_dead:
		get_parent().register_unit_position(self, current_region)
		if path:
			path.queue_free()
			path = null

func get_possible_paths():
	return current_region.get_neighbours()

func highlight_paths(line_manager):
	destination = null
	if path:
		path.queue_free()
		path = null
	line_manager.draw_lines(position, get_possible_paths())

func on_damage_dealt(damage, bonus = 0):
	var unit_defence = defence + bonus
	var damage_dealt = clamp(damage - unit_defence, 0, damage)
	current_health -= damage_dealt
	if current_health <= 0:
		current_health = 0
		on_death()
	$UnitHealth.value = current_health
	return is_dead

func on_death():
	is_dead = true
	queue_free()
