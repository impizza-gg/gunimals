extends Control

var player_leaderboard := "res://scenes/player_leaderboard/leaderboard_player.tscn"
@onready var player_list : VBoxContainer = $MarginContainer/PlayerList

func add_players(players: Dictionary) -> void:
	var counter := 0
	var players_ordered = []
	for key in players.keys():
		players_ordered.append(players[key])
	
	players_ordered.sort_custom(order_players)
	var pl_scene = load(player_leaderboard)
	
	for p in players_ordered:
		var pl = pl_scene.instantiate()
		player_list.add_child(pl)
		pl.set_data(p, counter == 0)
		counter += 1

func order_players(a: Dictionary, b: Dictionary) -> bool:
	if a["points"] < b["points"]:
		return false
	return true
