class_name Projectile extends Area2D

@export var direction := Vector2(1, 0)
@export var speed := 600.0

func _ready() -> void:
	top_level = true


func _process(delta: float) -> void:
	var movement = direction * speed * delta
	position += movement


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
