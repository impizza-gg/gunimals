extends Control

@onready var AmmoLabel := %AmmoLabel
@onready var ClipLabel := %ClipLabel

func _ready() -> void:
	Signals.connect("update_hud_ammo_current", update_ammo_current)
	Signals.connect("update_hud_ammo_max", update_ammo_max)
	Signals.connect("update_hud_clip_current", update_clip_current)
	Signals.connect("set_hud_visibility", set_visibility)
	Signals.connect("set_clip_label_visibility", set_clip_label_visibility)


func update_ammo_current(new_value: int) -> void:
	var max_ammo = AmmoLabel.text.split("/")[1]
	AmmoLabel.text = str(new_value) + "/" + max_ammo


func update_ammo_max(new_value: int) -> void:
	var current_ammo = AmmoLabel.text.split("/")[0]
	AmmoLabel.text = current_ammo + "/" + str(new_value)


func update_clip_current(new_value: int) -> void:
	ClipLabel.text = str(new_value)


func set_visibility(visibility: bool) -> void:
	visible = visibility


func set_clip_label_visibility(visibility: bool) -> void:
	ClipLabel.visible = visibility
