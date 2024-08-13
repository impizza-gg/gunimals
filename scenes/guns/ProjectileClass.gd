class_name Projectile extends CharacterBody2D

@export var direction := Vector2(1, 0)
@export var speed := 600.0
@export var bounces := false
@export var max_bounces := 6

var bounce := 0
var owner_id := -1
var damage := 1.0

func _ready() -> void:
	top_level = true
	velocity = Vector2(speed, 0).rotated(rotation)


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()
		if collider.is_in_group("wall"):
			if bounces:
				velocity = velocity.bounce(collision.get_normal())
				rotation = velocity.angle()
				
				bounce += 1
				if bounce >= max_bounces:
					queue_free()
			else:
				queue_free()

		if collider.is_in_group("player") or collider.is_in_group("dummy"):
			queue_free()
			if multiplayer.is_server():
				if collider.has_method("update_health"):
					collider.rpc("update_health", -damage)
					print("%s hit %s for %d" % [owner_id, collider.name, damage])
