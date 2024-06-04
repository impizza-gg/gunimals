extends Node2D

@onready var MainMenu := %MainMenu
var PlaygroundScene := preload("res://levels/playground/playground.tscn")

var default_cursor := load("res://assets/cursors/cursor_default.png")
var pointing_cursor := load("res://assets/cursors/cursor_select.png")

func _ready() -> void:
	# fazer por script dá mais opções de customização, nas settings só dá para setar o default
	Input.set_custom_mouse_cursor(default_cursor)
	Input.set_custom_mouse_cursor(pointing_cursor, Input.CURSOR_POINTING_HAND)


func _on_main_menu_start_playground() -> void:
	var playground := PlaygroundScene.instantiate()
	MainMenu.hide()
	add_child(playground)
	
