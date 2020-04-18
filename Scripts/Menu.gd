extends Control

class_name Menu

signal on_button_mouseover
signal on_button_exit
signal on_menu_status_change(status)

func on_hover():
	emit_signal("on_button_mouseover")

func on_hover_exit():
	emit_signal("on_button_exit")

func set_visible(status):
	visible = status
	emit_signal("on_menu_status_change", status)
