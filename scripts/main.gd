extends Node2D

var default_cursor := load("res://assets/cursors/cursor_default.png")
var crosshair := load("res://assets/cursors/crosshair.png")

func _ready() -> void:	
	var pointing_cursor := load("res://assets/cursors/cursor_select.png")
	var edit_cursor := load("res://assets/cursors/cursor_pen.png")
	Input.set_custom_mouse_cursor(default_cursor)
	Input.set_custom_mouse_cursor(pointing_cursor, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(edit_cursor, Input.CURSOR_IBEAM)
	Signals.set_crosshair.connect(change_cursor)
	Signals.button_hovered.connect(button_hover)
	Signals.button_click.connect(button_click)
	

func change_cursor(is_crosshair: bool) -> void:
	if is_crosshair:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, Vector2(26, 26))
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.set_custom_mouse_cursor(default_cursor)


func button_hover() -> void:
	$HoverPlayer.pitch_scale = randf_range(0.9, 1.1)
	$HoverPlayer.play()


func button_click() -> void:
	$ClickPlayer.pitch_scale = randf_range(0.9, 1.1)
	$ClickPlayer.play()
