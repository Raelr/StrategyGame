extends Node2D

export (Texture) var dot
export (Array) var segments
export (float) var dot_radius
export (float) var gap 
var dot_diameter

func set_destination(dest):
	var heading = dest - position
	var distance = heading.length()
	var direction = Vector2(heading.x / distance, heading.y / distance)
	dot_diameter = dot_radius * 2
	var dot_gap = (dot_diameter * gap)
	var dots = int(distance / dot_gap)
	var prev_pos = position
	for i in range(0, dots):
		var dot_pos = prev_pos + (direction * dot_gap)
		create_dot(dot_pos)
		prev_pos = dot_pos

func reset_line():
	for segment in segments:
		segment.queue_free()
	segments.clear()



func create_dot(dot_pos):
	var node = Sprite.new()
	node.texture = dot
	node.set_name("dot")
	add_child(node)
	node.scale = Vector2(dot_radius, dot_radius)
	node.position = dot_pos
	segments.push_back(node)

