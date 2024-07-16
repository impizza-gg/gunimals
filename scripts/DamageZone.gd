extends Area2D

@export var damage := 999.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("update_health"):
			body.rpc("update_health", -damage)
