tool
extends Selectable

# Each enum needs to own this...might be inefficient in the long run?
enum REGIONTYPE { grassLand, hills, mountains }

# Configuration Variables
export (Texture) var region_details
export (Texture) var region_overlay
export (Color) var occupied_color
export (REGIONTYPE) var region_type
export (Array) var neighbours
export (float) var change_duration
# Region Variables
export (String) var region_name
export (int) var wealth

var elapsed = 0.0

func _ready():
	set_selection_type(enums.SELECTION_TYPE.region)
	on_ready()
	change_region_sprite()

func get_details():
	return {
		"name": region_name,
		"wealth": wealth,
		"region type": region_type
	}

func _process(delta):
	if update:
		if Engine.editor_hint:
			change_region_sprite()
		set_occupied(occupied_color, delta)

func change_region_sprite():
	$Details.texture = region_details
	$Details/Overlay.texture = region_overlay
	outlined_sprite = $Details.get_path()

func set_occupied(overlay_color, delta): 
	transition_color(delta, $Details/Overlay, occupied_color)

func on_new_occupant(color):
	occupied_color = Color(color.r, color.g, color.b, 0.5)
	normal_color = occupied_color
	elapsed = 0.0
	update = true

# Thought - maybe move this into the Selectable class?
func transition_color(delta, ui, dest_color):
	if elapsed < change_duration:
		elapsed += delta
		ui.modulate = ui.modulate.linear_interpolate(dest_color, elapsed / change_duration)
		#change_outline(current_outline_color.linear_interpolate(border, elapsed / change_duration))
	elif elapsed >= change_duration:
		ui.modulate = dest_color
		elapsed = 0.0
		update = false

func _on_Area2D_mouse_entered():
	emit_signal("on_hover", self, get_type())

func _on_Area2D_mouse_exited():
	emit_signal("on_hover_exit", self, get_type())

func get_neighbours():
	var n = Array()
	for neighbour in neighbours:
		n.push_back(get_node(neighbour))
	return n
