extends Camera2D

export (Vector2) var mouse_offset
export (Vector2) var friction
export (float) var move_speed
export (float) var max_distance

const VELOCITY_DELTA = 0.01
const MAX_ACCELERATION = 100

onready var screen = get_viewport().size
onready var velocity = Vector2(0,0)
onready var max_dist = Vector2(position.x + max_distance, position.y + max_distance)
onready var min_dist = Vector2(position.x - max_distance, position.y - max_distance)

func above_threshold_x(mouse_pos):
	return mouse_pos.x > screen.x - mouse_offset.x

func below_threshold_x(mouse_pos):
	return mouse_pos.x < mouse_offset.x

func above_threshold_y(mouse_pos):
	return mouse_pos.y > screen.y - mouse_offset.y

func below_threshold_y(mouse_pos):
	return mouse_pos.y < mouse_offset.y

func _process(delta):
	position = position.linear_interpolate(adjust_velocity(), delta)

func adjust_velocity():
	var mouse = get_viewport().get_mouse_position()
	
	if above_threshold_x(mouse):
		velocity.x += move_speed
	if below_threshold_x(mouse):
		velocity.x -= move_speed
	if above_threshold_y(mouse):
		velocity.y += move_speed
	if below_threshold_y(mouse):
		velocity.y -= move_speed
	
	apply_friction()
	
	velocity = Vector2(clamp(velocity.x, -MAX_ACCELERATION, MAX_ACCELERATION), clamp(velocity.y, -MAX_ACCELERATION, MAX_ACCELERATION))
	
	if abs(velocity.x) < VELOCITY_DELTA:
		velocity.x = 0
	if abs(velocity.y) < VELOCITY_DELTA:
		velocity.y = 0
	
	return Vector2(clamp((position.x + velocity.x), min_dist.x, max_dist.x), clamp((position.y + velocity.y), min_dist.y, max_dist.y))

func apply_friction():
	if velocity.x > 0:
		velocity.x -= friction.x
	elif velocity.x < 0:
		velocity.x += friction.x
	if velocity.y > 0:
		velocity.y -= friction.y
	elif velocity.y < 0:
		velocity.y += friction.y
