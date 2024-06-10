extends Node2D

var default_cursor := load("res://assets/cursors/cursor_default.png")
var pointing_cursor := load("res://assets/cursors/cursor_select.png")
var edit_cursor := load("res://assets/cursors/cursor_pen.png")

func _ready() -> void:
	# fazer por script dá mais opções de customização, nas settings só dá para setar o default
	Input.set_custom_mouse_cursor(default_cursor)
	Input.set_custom_mouse_cursor(pointing_cursor, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(edit_cursor, Input.CURSOR_IBEAM)
