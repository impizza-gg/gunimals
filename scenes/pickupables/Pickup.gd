class_name Pickup extends RigidBody2D

@export var item_scene := "res://scenes/guns/example_automatic/automatic_gun.tscn"

@rpc("any_peer", "call_local")
func rpc_impulse(force: Vector2):
	apply_impulse(force)
