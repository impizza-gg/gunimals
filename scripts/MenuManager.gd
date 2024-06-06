extends CanvasLayer

@onready var PauseMenu = $PauseMenu

func _ready() -> void:
	Signals.toggle_pause_menu.connect(toggle_pause_menu)
	
	
func toggle_pause_menu() -> void:
	PauseMenu.visible = not PauseMenu.visible
	Signals.paused = PauseMenu.visible


func _on_resume_button_pressed() -> void:
	toggle_pause_menu()
