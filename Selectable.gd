tool
extends Node2D
class_name Selectable

const enums = preload("res://Scripts/FactionData.gd")

export (bool) var update = false
export (Texture) var outlined_sprite

var selection_type

signal on_hover(selectable, type)
signal on_hover_exit(selectable, type)
signal on_press

func on_ready():
	var world = get_tree().get_root().get_child(0)
	connect("on_hover", world, "moused_over")
	connect("on_hover_exit", world, "mouse_left")

func set_selection_type(type):
	selection_type = type

func get_type():
	return selection_type

func set_outline(color):
	outlined_sprite.material.set_shader_param("outline_color", color)
