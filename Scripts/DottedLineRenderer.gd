extends Node2D

export (Texture) var dot_sprite
export (Array) var segments
export (float) var dot_radius
export (float) var gap 
export (float, 0.0, 1.0) var revealed
var dot_diameter
var elapsed = 0.0

func set_destination(dest):
	var heading = dest - position
	var distance = heading.length()
	var direction = Vector2(heading.x / distance, heading.y / distance)
	
	dot_diameter = dot_radius * 2
	var dot_gap = (dot_diameter * gap)
	var dots = int(distance / dot_gap)
	var prev_pos = position
	for i in range(0, dots):
		var dot_pos = get_next_step(prev_pos, direction * dot_gap)
		create_dot(dot_pos, dot_sprite)
		prev_pos = dot_pos

func get_next_step(pos, direction):
	return pos + direction

func reset_line():
	for segment in segments:
		segment.queue_free()
	segments.clear()

func create_dot(dot_pos, sprite, custom_scale = null):
	var node = Sprite.new()
	node.texture = sprite
	node.set_name("dot")
	add_child(node)
	if not custom_scale:
		node.scale = Vector2(dot_radius, dot_radius)
	else:
		node.scale = custom_scale
	node.position = dot_pos
	segments.push_back(node)

func _process(delta):
	pass
