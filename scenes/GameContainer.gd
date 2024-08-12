extends Node

@onready var MainMenu := %MainMenu
@onready var WaitingRoom := %WaitingRoom

@onready var PlaygroundScene := preload("res://levels/playground/playground.tscn")
@onready var PlayerScene := preload("res://scenes/player/player.tscn")

@onready var mapPool : Array[String] = [
	"res://levels/playground/playground.tscn"
]
@onready var firstMap := mapPool[0]

@onready var MultiplayerManager := $"../MultiplayerManager"
@onready var MapSpawner := $"../MapSpawner"
@onready var PlayerSpawner := $"../PlayerSpawner"
@onready var WaitTimer : Timer = $"../Timer"
@onready var WaitTimer2 : Timer = $"../Timer2"

var max_rounds := 10
var current_round := 0
var level: Node

#var default_settings := {
	#"current_round": 0,
	#"rounds": 10
#}
#var room_settings := {}

func _ready() -> void:
	WaitingRoom.connect("game_started", game_started)
	MultiplayerManager.connect("new_room", new_room)
	PlayerSpawner.spawn_function = playerSpawnFunction
	MapSpawner.spawn_function = mapSpawnFunction
	Signals.player_death.connect(on_player_death)
	WaitingRoom.add_round.connect(round_config)
	WaitTimer2.timeout.connect(transition)
	WaitTimer.timeout.connect(round_end)


func new_room() -> void:
	#room_settings = default_settings.duplicate(true)
	max_rounds = 10
	current_round = 0


func on_player_death(id: int) -> void:
	if MultiplayerManager.connected_players.has(id):
		MultiplayerManager.connected_players[id]["alive"] = false
		
		var winner := 0
		for pid in MultiplayerManager.connected_players:
			if pid == id:
				continue 
			if MultiplayerManager.connected_players[pid]["alive"]:
				if winner == 0:
					winner = pid
				else:
					winner = 0
					break
					
		if winner != 0:
			MultiplayerManager.connected_players[winner]["points"] += 1
			current_round += 1
			WaitTimer2.start()


func transition() -> void:
	$"../CanvasLayer/SceneTransition".rpc("playTransition", true)
	WaitTimer.start()


func round_end() -> void:
	var new_map = mapPool.pick_random()
	call_deferred("change_map", new_map)
	

#@rpc("any_peer", "call_local")
#func clear_game_w() -> void:
	#call_deferred("clear_game")


@rpc("any_peer", "call_local")
func clear_game() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	
func change_map(map: String) -> void:	
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	rpc("clear_game")

	MapSpawner.spawn({
		"map": map
	})
	
	var counter := 0
	for id in MultiplayerManager.connected_players:
		MultiplayerManager.connected_players[id]["alive"] = true
		var player_data = MultiplayerManager.connected_players[id]
		player_data.counter = counter
		player_data.id = id
		PlayerSpawner.spawn(player_data)
		counter += 1
	$"../CanvasLayer/SceneTransition".rpc("playTransition")
	$"../CanvasLayer/Countdown".rpc("playCountdown")


func mapSpawnFunction(map_data: Dictionary) -> Node:
	var mapscene = load(map_data["map"])
	var map = mapscene.instantiate()
	level = map
	return map


func playerSpawnFunction(player_data: Dictionary) -> Node:
	var player := PlayerScene.instantiate()
	player.name = str(player_data.id) # nome do nodo
	player.player_name = player_data.player_name
	player.character_type = player_data.character
	player.position = Vector2(400, 500) + player_data.counter * Vector2(700, 0)
	return player


# chamado somente no server
# players são instanciados no server e replicados pelo MultiplayerSpawner
func game_started() -> void:
	$"../CanvasLayer/SceneTransition".rpc("playTransition", true)
	
	MapSpawner.spawn({
		"map": firstMap
	})
	
	print(MultiplayerManager.connected_players)
	var counter := 0
	for id in MultiplayerManager.connected_players:
		var player_data = MultiplayerManager.connected_players[id]
		player_data.counter = counter
		player_data.id = id
		PlayerSpawner.spawn(player_data)
		counter += 1
		
	game_started_all.rpc()
	

@rpc("authority", "call_local")
func game_started_all() -> void:
	WaitingRoom.hide()
	$"../CanvasLayer/Background".hide()
	
	Signals.set_crosshair.emit(true)
	$"../CanvasLayer/SceneTransition".rpc("playTransition")
	$"../CanvasLayer/Countdown".rpc("playCountdown")
	
	
func _on_main_menu_start_playground() -> void:
	var playground := PlaygroundScene.instantiate()
	MainMenu.hide()
	$"../CanvasLayer/Background".hide()
	
	add_child(playground)
	PlayerSpawner.spawn({
		"player_name": "Player",
		"id": 1,
		"counter": 0
	})


func round_config(add: bool) -> void:
	var i = 1 if add else -1
	max_rounds += i
	max_rounds = clamp(max_rounds, 1, 9999)
	WaitingRoom.rpc("config_updates", {
		"max_rounds": max_rounds
	})
