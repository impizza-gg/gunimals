extends Control

@onready var AmmoLabel := $AmmoLabel

func _ready() -> void:
	Signals.connect("update_hud_ammo_current", update_ammo_current)
	Signals.connect("update_hud_ammo_max", update_ammo_max)


func update_ammo_current(new_value: int) -> void:
	var max_ammo = AmmoLabel.text.split("/")[1]
	AmmoLabel.text = str(new_value) + "/" + max_ammo


func update_ammo_max(new_value: int) -> void:
	var current_ammo = AmmoLabel.text.split("/")[0]
	AmmoLabel.text = current_ammo + "/" + str(new_value)
