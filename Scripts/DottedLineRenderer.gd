extends Node2D

export (Texture) var dot_sprite
export (Texture) var arrow_end
export (Array) var segments
export (float) var dot_radius
export (float) var gap 
export (float, 0.0, 1.0) var revealed
export (float) var reveal_duration

var loaded_asset = preload("res://Scenes/Dot.tscn")
var dot_diameter
var dot_max = 0
var elapsed = 0.0

func set_destination(dest, line_color):
	var heading = dest - position
	var distance = heading.length()
	var direction = Vector2(heading.x / distance, heading.y / distance)
	dot_diameter = dot_radius * 2
	var dot_gap = (dot_diameter * gap)
	dot_max = int(distance / dot_gap)
	var prev_pos = position
	for i in range(0, dot_max):
		var dot_pos = get_next_step(prev_pos, direction * dot_gap)
		var sprite = dot_sprite
		if arrow_end and i == dot_max - 1:
			sprite = arrow_end
		create_dot(dot_pos, sprite, line_color, dest)
		prev_pos = dot_pos

func get_next_step(pos, direction):
	return pos + direction

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
	var dir = direction - node.position
	print(node.position.angle_to_point(direction))
	node.rotation = node.position.angle_to_point(direction)
	segments.push_back(node)
