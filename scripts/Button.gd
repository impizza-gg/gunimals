extends Control

func _on_focus_entered() -> void:
	Signals.button_hovered.emit()


func _on_pressed() -> void:
	Signals.button_click.emit()


func _on_mouse_entered() -> void:
	Signals.button_hovered.emit()
