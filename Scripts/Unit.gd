tool
extends Area2D

# TODO: Strip this class of specific functionality and make it more generic for reuse. 
# Possibly make it a class_name so that it can be used by multiple units. 

const enums = preload('res://Scripts/FactionData.gd')

export (enums.FACTION) var faction
export (Color) var unitColor
export (Color) var outline_color
export (Color) var faction_color
export (bool) var update
export (float) var move_speed

export (int) var defence
export (int) var attack
export (int) var max_health
export (int) var current_health
export (String) var unit_name

var current_region = null
var destination = null
var elapsed = 0.0
var line_manager = null
var path = null
var is_dead = false
var init = false

signal on_move_command(region, faction, unit)
signal finished_move

func _ready():
	$Unit.material.set_shader_param("unit_color", faction_color)
	$Unit/AnimationPlayer.play("idle")
	var world = get_tree().get_root().get_child(0)
	world.connect("on_turn_ended", self, "register_position")
	$UnitHealth.max_value = max_health
	$UnitHealth.value = current_health

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
	change_outline(Color.yellow)
	if not $Unit/AnimationPlayer.current_animation == "salute" and not $Unit/AnimationPlayer.current_animation == "":
		$Unit/AnimationPlayer.play("salute")

func set_deselected():
	change_outline(Color.black)
	$Unit/AnimationPlayer.play("desalute")
	$Unit/AnimationPlayer.queue("idle")

func get_details():
	return {
		"type": "unit",
		"name": unit_name,
		"attack": attack,
		"defence": defence,
		"health" : {
			"current" : current_health,
			"max" : max_health
		},
		"color" : faction_color
	}

func reset():
	set_deselected()

func reset_move():
	var neighbours = get_possible_paths()
	for neighbour in neighbours:
		get_parent().deregister_move(neighbour, self)

func change_outline(color):
	$Unit.material.set_shader_param("outline_color", color)

func _on_Area2D_mouse_entered():
	get_parent().moused_over(self)

func _on_Area2D_mouse_exited():
	get_parent().mouse_left(self)

func _on_Unit_area_entered(area):
	if not current_region and not init:
		set_current_region(area)
		init = true

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
	for region in n:
		if region == moused_element:
			get_parent().deregister_move(destination, self)
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
			get_parent().register_move_command(region, faction, self)
			break

func register_position():
	if not is_dead:
		get_parent().register_unit_position(self, faction, current_region)
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
