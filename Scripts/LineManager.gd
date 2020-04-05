extends Node2D

export (Array) var arrow_end_sprites
export (Texture) var segment_sprite
export (bool) var is_pixel_art
export (float) var dot_radius
export (float) var gap
export (float) var dot_spawn_duration
export (Color) var default_line_color

var loaded_asset = preload("res://Scenes/DottedLineRenderer.tscn")
var lines = Array()
var all_drawn = false

# Get a list of positions.
# Iterate over them and instatiate new lindes accordingly
func draw_lines(origin, destinations):
	if not all_drawn:
		reset()
		position = origin
		for place in destinations:
			var line_details = {
				"dest_name" : place.region_name,
				"line" : null
			}
			spawn_line(origin, place.global_position, line_details)
		all_drawn = true

func draw_single_line(origin, destination):
	var line_details = {
		"dest_name" : destination.region_name,
		"line" : null
	}
	spawn_line(origin, destination.global_position, line_details)

func spawn_line(origin, dest, details, color = null):
	var node = loaded_asset.instance()
	node.set_name("Line")
	add_child(node)
	details["line"] = node
	lines.push_back(details)
	node.on_init(arrow_end_sprites, segment_sprite, is_pixel_art, dot_radius, gap, dot_spawn_duration, default_line_color)
	node.set_destination(origin, dest, color)

func reset_exception(region_name):
	var lines_to_delete = Array()
	for line in lines:
		if line["dest_name"] == region_name:
			line["line"].change_color(Color.white)
		else:
			lines_to_delete.push_back(line)
	for line in lines_to_delete:
		lines.erase(line)
		line["line"].queue_free()
	all_drawn = false

func select_arrow(region_name):
	for line in lines:
		if line["dest_name"] == region_name:
			if not line["line"].visible:
				line["line"].visible = true
			line["line"].change_color(Color.white)
		else:
			line["line"].visible = false
	all_drawn = false

func reset():
	for line in lines:
		line["line"].queue_free()
	lines.clear()
	all_drawn = false
