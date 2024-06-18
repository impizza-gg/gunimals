extends Node2D

var players_in_area = []
var state = "spawned"
@export var item_scene = "res://scenes/guns/shotgun/shotgun.tscn"

func _ready():
	pass

func _process(delta):
	if state == "spawned":
		check_for_player_interaction()
		


func check_for_player_interaction():
	for player in players_in_area:
		if player.is_interacting():
			rpc("player_interaction")
			player.GunManager.rpc("equip_gun", item_scene)
			break

@rpc("any_peer", "call_local")
func player_interaction():
	state = "picked_up"
	players_in_area.clear()
	queue_free()

func _on_pickable_area_body_entered(body):
	print(body)
	if body.is_in_group("player"):
		players_in_area.append(body)
		print("entroo")


func _on_pickable_area_body_exited(body):
	print("saiu")
	if body.is_in_group("player"):
		players_in_area.erase(body)
		print("saiuu")
