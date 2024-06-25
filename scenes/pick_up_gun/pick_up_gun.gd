extends Node2D

@export var item_scene := "res://scenes/guns/shotgun/shotgun.tscn"
		
#var players_in_area: Array[Node2D] = []
#var state := "spawned"
#@export var item_scene := "res://scenes/guns/shotgun/shotgun.tscn"
#
#
#func _ready() -> void:
	#pass
#
#
#func _process(_delta) -> void:
	#if state == "spawned":
		#check_for_player_interaction()
#
#
#func check_for_player_interaction() -> void:
	#for player in players_in_area:
		#if player.is_interacting():
			#rpc("player_interaction")
			#player.GunManager.rpc("equip_gun", item_scene)
			#break
#
#
#@rpc("any_peer", "call_local")
#func player_interaction() -> void:
	#state = "picked_up"
	#players_in_area.clear()
	#queue_free()
#
#
#func _on_pickable_area_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#players_in_area.append(body)
#
#
#func _on_pickable_area_body_exited(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#players_in_area.erase(body)
