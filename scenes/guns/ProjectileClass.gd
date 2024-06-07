class_name Projectile extends Area2D

@export var direction := Vector2(1, 0)
@export var speed := 600.0
var owner_id := -1
var damage := 1.0

func _ready() -> void:
	top_level = true


func _process(delta: float) -> void:
	var movement = direction * speed * delta
	position += movement


func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if multiplayer.is_server():
		if body.is_in_group("player"):
			if body.has_method("update_health"):
				body.rpc("update_health", -damage)
				print("%s hit %s for %d" % [owner_id, body.name, damage])
