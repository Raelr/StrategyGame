extends Camera2D

onready var screen = get_viewport().size
export (Vector2) var mouse_offset
export (float) var move_speed

var above_x = false
var below_x = false
var above_y = false
var below_y = false

func out_of_bounds():
	var mouse = get_viewport().get_mouse_position()
	var x = mouse.x > screen.x - mouse_offset.x or mouse.x < mouse_offset.x
	var y = mouse.y > screen.y - mouse_offset.y or mouse.y < mouse_offset.y
	return x or y

func above_threshold_x(mouse_pos):
	return mouse_pos.x > screen.x - mouse_offset.x

func below_threshold_x(mouse_pos):
	return mouse_pos.x < mouse_offset.x

func above_threshold_y(mouse_pos):
	return mouse_pos.y > screen.y - mouse_offset.y

func below_threshold_y(mouse_pos):
	return mouse_pos.y < mouse_offset.y

func _process(delta):
	var velocity = adjust_velocity(Vector2(0,0))
	position = position.linear_interpolate(velocity, delta)

func adjust_velocity(velocity):
	var mouse = get_viewport().get_mouse_position()
	if above_threshold_x(mouse):
		velocity.x += move_speed
	if below_threshold_x(mouse):
		velocity.x -= move_speed
	if above_threshold_y(mouse):
		velocity.y += move_speed
	if below_threshold_y(mouse):
		velocity.y -= move_speed
	var next_pos = position + velocity
	return next_pos


