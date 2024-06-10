extends Node

const SETTINGS_PATH := "user://user_data.save"
const default_settings := {
	"player_name": "",
	"locale": "en"
}

var current_settings := default_settings

func _ready() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var settings_file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		var content := settings_file.get_as_text()
		var settings_dict = JSON.parse_string(content)
		if not settings_dict:
			print("Error loading settings file")
			create_settings_file()
			return
		check_keys(settings_dict)
		current_settings = settings_dict
		print(current_settings)
		# não tá salvando 
	else:
		create_settings_file()


func _notification(type):
	if type == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Saving config file...")
		var settings_file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		settings_file.store_string(JSON.stringify(current_settings))
		get_tree().quit() # default behavior


func create_settings_file() -> void:
	var new_file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	print("created new file")
	new_file.store_string(JSON.stringify(default_settings))


func check_keys(settings: Dictionary) -> void:
	for key in default_settings.keys():
		if not settings.has(key):
			settings[key] = default_settings[key]
