extends Node2D

export (Texture) var dot_sprite
export (Array) var arrow_end
export (bool) var is_pixel_art_arrow
export (Array) var segments
export (float) var dot_radius
export (float) var gap 
export (float, 0.0, 1.0) var revealed
export (float) var reveal_duration

var loaded_asset = preload("res://Scenes/Dot.tscn")
var dot_diameter
var dot_max = 0
var elapsed = 0.0

func set_destination(origin, dest, line_color):
	var heading = dest - origin
	var distance = heading.length()
	var direction = Vector2(heading.x / distance, heading.y / distance)
	dot_diameter = dot_radius * 2
	var dot_gap = (dot_diameter * gap)
	dot_max = int(distance / dot_gap)
	var prev_pos = position
	for i in range(0, dot_max):
		var dot_pos = get_next_step(prev_pos, direction * dot_gap)
		var sprite = dot_sprite
		var dir = null
		if is_pixel_art_arrow and i == dot_max - 1:
			dir = direction
			sprite = get_arrow_direction(dir)
		create_dot(dot_pos, sprite, line_color, dir)
		prev_pos = dot_pos

func get_next_step(pos, direction):
	return pos + direction

func get_arrow_direction(dir):
	if (abs(dir.x) < 0.3 and (abs(dir.y) > 0.3) and sign(dir.y) == -1):
		return arrow_end[0]
	elif abs(dir.x) > 0.3 and abs(dir.y) > 0.3 and (sign(dir.x) == 1 and sign(dir.y) == -1):
		return arrow_end[1]
	elif abs(dir.x) > 0.3 and abs(dir.y) < 0.3 and sign(dir.x) == 1:
		return arrow_end[2]
	elif abs(dir.x) > 0.3 and abs(dir.y) > 0.3 and (sign(dir.x) == 1 and sign(dir.y) == 1):
		return arrow_end[3]
	elif abs(dir.x) < 0.3 and abs(dir.y) > 0.3 and (sign(dir.x) == -1 and sign(dir.y) == 1):
		return arrow_end[4]
	elif abs(dir.x) > 0.3 and abs(dir.y) > 0.3 and (sign(dir.x) == -1 and sign(dir.y) == 1):
		return arrow_end[5]
	elif abs(dir.x) > 0.3 and abs(dir.y) < 0.3 and (sign(dir.x) == -1):
		return arrow_end[6]
	elif abs(dir.x) > 0.3 and abs(dir.y) > 0.3 and (sign(dir.x) == -1 and sign(dir.y) == -1):
		return arrow_end[7]

func reset_line():
	for segment in segments:
		segment.queue_free()
	segments.clear()
	dot_max = 0

func create_dot(dot_pos, sprite, line_color, direction):
	var node = loaded_asset.instance()
	node.texture = sprite
	node.set_name("dot")
	add_child(node)
	node.scale = Vector2(dot_radius, dot_radius)
	node.position = dot_pos
	segments.push_back(node)

func on_init(arrows, segment, is_pixel, radius, gap):
	arrow_end = arrows
	dot_sprite = segment
	is_pixel_art_arrow = is_pixel
	dot_radius = radius
	self.gap = gap
	
