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

func _ready() -> void:
	var user_data := load_config()
	if user_data.has('name'):
		HostNameInput.text = user_data['name']
		JoinNameInput.text = user_data['name']
		
	focus_button()


func _on_host_button_pressed() -> void:
	HostPopup.show()


func _on_join_button_pressed() -> void:
	JoinPopup.show()
	

func _on_visibility_changed() -> void:
	if visible:
		focus_button()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func focus_button() -> void:
	if ButtonsVBox:
		var button: Button = ButtonsVBox.get_child(0)
		if button is Button:
			button.grab_focus()


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
	if input.text.is_empty():
		input.placeholder_text = "IP is required"
		return false
	else:
		input.placeholder_text = "IP"
		# TODO: mensagem de erro
		return input.text.is_valid_ip_address()


func name_validity(input: LineEdit) -> bool:
	input.text = input.text.strip_edges()
	if input.text.is_empty():
		input.placeholder_text = "Name is required"
		return false
	else:
		input.placeholder_text = "Name"
		save_name(input.text)
		return true


func save_name(playerName: String) -> void:
	# Provavelmente vai ser necessário deixar mais geral e mudar de lugar essa função
	# para tratar outras configurações
	# ex: save_configs(configs: Dictionary) -> void: 
	# ... sobreescreve as configs no dicionário e mantém as demais como estavam
	
	var file := FileAccess.open("user://user_data.save", FileAccess.READ_WRITE)
	var content := file.get_as_text()
	var user_data = JSON.parse_string(content)
	if not user_data:
		user_data = {}
	user_data['name'] = playerName
	file.store_string(JSON.stringify(user_data))
	file.close()


func load_config() -> Dictionary:
	# No momento o jogo busca os dados do usuário, que é só o nome que ele utilizou da última vez.
	var file = FileAccess.open("user://user_data.save", FileAccess.READ)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	if not data: data = {}
	file.close()
	return data
	

func _on_playground_button_pressed() -> void:
	start_playground.emit()
