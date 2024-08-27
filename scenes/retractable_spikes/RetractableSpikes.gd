extends Node2D

var active = true

@onready var dmg_area : Area2D = $Area2D
@onready var sprites : Node = $Sprites

@rpc("any_peer", "call_local")
func interact() -> void:
	print("interacting with retractible spikes")
	active = not active
	dmg_area.monitoring = active
	for sprite in sprites.get_children():
		if active:
			sprite.play("up")
		else:
			sprite.play_backwards("up")
