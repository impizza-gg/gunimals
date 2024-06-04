extends Control

func _ready() -> void:
	pass

func ui_update(current_ammo: int):
	print("oi")
	$Label.text = str(current_ammo)
