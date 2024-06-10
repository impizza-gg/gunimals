extends Control

signal create_room(name: String)
signal join_room(name: String, ipPort: String)
signal start_playground

@onready var ButtonsVBox := %ButtonsVBox
@onready var HostPopup := $HostPopup
@onready var JoinPopup := $JoinPopup
@onready var HostNameInput := %HostNameInput
@onready var JoinNameInput := %JoinNameInput
@onready var IPInput := %IPInput
@onready var BRButton := %BR_Button
@onready var ENButton := %EN_Button

func _ready() -> void:
	HostNameInput.text = Settings.current_settings["player_name"]
	JoinNameInput.text = Settings.current_settings["player_name"]
	if Settings.current_settings["locale"] == "br":
		BRButton.emit_signal("pressed")
		BRButton.set_pressed_no_signal(true)
		ENButton.set_pressed_no_signal(false)
	focus_first_button()


func _on_host_button_pressed() -> void:
	# DEBUG
	HostNameInput.text = "Host"
	HostPopup.show()


func _on_join_button_pressed() -> void:
	# DEBUG
	JoinNameInput.text = "Client"
	JoinPopup.show()
	

func _on_visibility_changed() -> void:
	if visible:
		focus_first_button()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func focus_first_button() -> void:
	if ButtonsVBox:
		for child in ButtonsVBox.get_children():
			if child is Button and not child.disabled:
				child.grab_focus()
				break


func _on_popup_host_button_pressed() -> void:
	if name_validity(HostNameInput):
		HostPopup.hide()
		create_room.emit(HostNameInput.text)
	

func _on_popup_join_button_pressed() -> void:
	if name_validity(JoinNameInput):
		if ip_validity(IPInput):
			JoinPopup.hide()
			join_room.emit(JoinNameInput.text, IPInput.text)
		else:
			print("invalid ip")


func ip_validity(input: LineEdit) -> bool:
	input.text = input.text.strip_edges()
	var ip_valid := input.text.is_valid_ip_address()
	if ip_valid:
		input.placeholder_text = "IP"
	else:
		input.placeholder_text = tr("IP_WARNING")
	return ip_valid 


func name_validity(input: LineEdit) -> bool:
	input.text = input.text.strip_edges()
	if input.text.is_empty():
		input.placeholder_text = tr("NAME_WARNING")
		return false
	else:
		input.placeholder_text = tr("NAME_PLACEHOLDER")
		Settings.current_settings["player_name"] = input.text
		return true
		

func _on_playground_button_pressed() -> void:
	start_playground.emit()


func _on_br_button_pressed() -> void:
	set_locale("br")


func _on_en_button_pressed() -> void:
	set_locale("en")


func set_locale(locale: String) -> void:
	if locale == "br" or locale == "en":
		TranslationServer.set_locale(locale)
		Settings.current_settings["locale"] = locale
	else:
		print("Error: unknown locale")
