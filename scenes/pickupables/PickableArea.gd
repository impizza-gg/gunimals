extends Area2D

func hover() -> void:
	$"../LabelContainer/Label".visible = true


func unhover() -> void:
	$"../LabelContainer/Label".visible = false


func interact(player: Node) -> void:
	player.GunManager.rpc("equip_gun", $"..".item_scene, $"..".clips, $"..".current_ammo)
	$"..".queue_free()
