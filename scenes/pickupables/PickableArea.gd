extends Area2D

func hover() -> void:
	$"../Label".visible = true


func unhover() -> void:
	$"../Label".visible = false


func interact(player: Node) -> void:
	player.GunManager.rpc("equip_gun", $"..".item_scene)
	$"..".queue_free()
