extends Control

signal leave_room
signal game_started

@onready var PlayerList := %PlayerList
@onready var PlayerName := preload("res://scenes/player_label/player_label.tscn")
@onready var spawner := %MultiplayerSpawner
@onready var StartButton := %StartButton

func _ready() -> void:
	# foi uma desgraça chegar aqui
	spawner.spawn_function = spawnMenuPlayer


var ip: String : 
	set(value):
		%IP_Label.text = value


func _on_back_button_pressed() -> void:
	leave_room.emit()


func spawnMenuPlayer(data: Dictionary):
	# tudo isso porque o multiplayerspawner não tava sincronizando variáveis dentro dos nodos 
	var myAdminStatus = multiplayer.is_server()
	var isSelf = data['id'] == multiplayer.get_unique_id()
	
	var playerLabel := PlayerName.instantiate()
	playerLabel.name = str(data['id'])
	playerLabel.id = data['id']
	playerLabel.playerName = data['playerName']
	playerLabel.admin = data['admin']
	playerLabel.show_controls = myAdminStatus and not isSelf
	
	return playerLabel


func _on_multiplayer_manager_player_added(id: int, playerName: String, admin: bool) -> void:	
	spawner.spawn({
		'id': id,
		'playerName': playerName,
		'admin': admin
	})


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(%IP_Label.text)


func clear_player_list() -> void:
	for player in PlayerList.get_children():
		PlayerList.remove_child(player)
		player.queue_free()


func _on_multiplayer_manager_player_disconnected_signal(id: int) -> void:
	# não sei se é o melhor método
	for player in PlayerList.get_children():
		if player.name == str(id):
			PlayerList.remove_child(player)
			player.queue_free()


func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		game_started.emit()
	
