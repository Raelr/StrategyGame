extends Camera2D

export (Vector2) var mouse_offset
export (Vector2) var friction
export (float) var move_speed
export (float) var max_distance
export (float) var zoom_speed

const VELOCITY_DELTA = 0.01
const MAX_ACCELERATION = 50
const MIN_ZOOM_FACTOR = 0.8
const MAX_ZOOM_FACTOR = 1.1

onready var screen = get_viewport().size
onready var velocity = Vector2(0,0)
onready var max_dist = Vector2(position.x + max_distance, position.y + max_distance)
onready var min_dist = Vector2(position.x - max_distance, position.y - max_distance)

func above_threshold(pos, threshold):
	return pos > threshold

func below_threshold(pos, threshold):
	return pos < threshold
 
func _process(delta):
		position = position.linear_interpolate(adjust_velocity(), delta)

func adjust_velocity():
	var mouse = get_viewport().get_mouse_position()
	
	if above_threshold(mouse.x, screen.x - mouse_offset.x):
		velocity.x += move_speed
	if below_threshold(mouse.x, mouse_offset.x):
		velocity.x -= move_speed
	if above_threshold(mouse.y, screen.y - mouse_offset.y):
		velocity.y += move_speed
	if below_threshold(mouse.y, mouse_offset.y):
		velocity.y -= move_speed
	
	velocity.x = apply_friction(velocity.x, friction.x)
	velocity.y = apply_friction(velocity.y, friction.y)
	
	velocity = Vector2(clamp(velocity.x, -MAX_ACCELERATION, MAX_ACCELERATION), clamp(velocity.y, -MAX_ACCELERATION, MAX_ACCELERATION))
	
	if abs(velocity.x) < VELOCITY_DELTA:
		velocity.x = 0
	if abs(velocity.y) < VELOCITY_DELTA:
		velocity.y = 0
	
	return Vector2(clamp((position.x + velocity.x), min_dist.x, max_dist.x), clamp((position.y + velocity.y), min_dist.y, max_dist.y))

func apply_friction(v_dimension, friction):
	if v_dimension > 0:
		v_dimension -= friction
	elif v_dimension < 0:
		v_dimension += friction
	return v_dimension

func _input(event):
	if event is InputEventMagnifyGesture:
		var zoom_velocity = Vector2(0,0)
		if event.factor > 1:
			zoom_velocity.x -= zoom_speed
			zoom_velocity.y -= zoom_speed
		else:
			zoom_velocity.x += zoom_speed
			zoom_velocity.y += zoom_speed
		
		zoom.x = clamp(zoom.x + zoom_velocity.x, MIN_ZOOM_FACTOR, MAX_ZOOM_FACTOR)
		zoom.y = clamp(zoom.y + zoom_velocity.y, MIN_ZOOM_FACTOR, MAX_ZOOM_FACTOR)
