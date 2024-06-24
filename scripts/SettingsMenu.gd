extends Control

@onready var return_to_main := true

func _on_back_button_pressed() -> void:
	visible = false
	if return_to_main:
		%MainMenu.visible = true
	else:
		$"../PauseMenu".visible = true


# Pause Menu Settings
func _on_settings_button_pressed() -> void:
	$"../PauseMenu".visible = false
	visible = true
	return_to_main = false
