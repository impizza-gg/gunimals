extends CanvasLayer

@onready var PauseMenu = $PauseMenu

func _ready() -> void:
	Signals.toggle_pause_menu.connect(toggle_pause_menu)
	
	
func _on_resume_button_pressed() -> void:
	toggle_pause_menu()


func toggle_pause_menu() -> void:
	if Signals.settings_menu:
		Signals.settings_back.emit()
		return
		
	PauseMenu.visible = not PauseMenu.visible
	Signals.paused = PauseMenu.visible
	Signals.set_crosshair.emit(not Signals.paused)
	if Signals.paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else: 
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _on_leave_game_pressed() -> void:
	$"../MultiplayerManager".back()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PauseMenu.visible = false
	Signals.paused = false
	Signals.set_crosshair.emit(false)


func _on_end_game_button_pressed() -> void:
	$"../MultiplayerManager".back()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	PauseMenu.visible = false
	Signals.paused = false
	Signals.set_crosshair.emit(false)
