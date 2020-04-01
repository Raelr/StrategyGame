extends Node2D

export (Array) var arrow_end_sprites
export (Texture) var segment_sprite
export (bool) var is_pixel_art
export (float) var dot_radius
export (float) var gap

var loaded_asset = preload("res://Scenes/DottedLineRenderer.tscn")
var arrows = Array()

# Get a list of positions.
# Iterate over them and instatiate new lindes accordingly
func draw_lines(origin, destinations):
	for place in destinations:
		spawn_line(origin, place.global_position, Color.crimson)

func spawn_line(origin, dest, color):
	var node = loaded_asset.instance()
	node.set_name("Line")
	add_child(node)
	arrows.push_back(node)
	node.on_init(arrow_end_sprites, segment_sprite, is_pixel_art, dot_radius, gap)
	node.set_destination(origin, dest, color)
	
