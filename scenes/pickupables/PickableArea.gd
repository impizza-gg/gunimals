extends Area2D

func hover() -> void:
	$"../LabelContainer/Label".visible = true
	pass


func unhover() -> void:
	$"../LabelContainer/Label".visible = false
	pass


func interact(player: Node) -> void:
	player.GunManager.rpc("equip_gun", $"..".item_scene, $"..".clips, $"..".current_ammo)
	rpc("clear_all")
	
	
@rpc("any_peer", "call_local")
func clear_all() -> void:
	$"..".queue_free()
