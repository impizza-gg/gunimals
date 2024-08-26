extends RigidBody2D

@export var direction := Vector2(1, 0)
@export var speed := 700.0
@export var force := 9000.0
var owner_id := -1
var damage := 20.0

func _ready() -> void:
	top_level = true
	apply_impulse(direction * speed)
	

func _on_timer_timeout() -> void:
	$Sprite2D.visible = false
	$GPUParticles2D.emitting = true
	$DeleteTimer.start()
	if multiplayer.is_server():
		var bodies = $Area2D.get_overlapping_bodies()
		for body in bodies:
			var impact_direction = body.global_position - global_position
			var distance = impact_direction.length() / 5
			impact_direction = impact_direction.normalized()
			var force_vector = impact_direction * (force / (distance))
			force_vector = force_vector.clamp(Vector2(-1000, -50), Vector2(1000, 50))
			print("explosion")
			if body.has_method("update_health"):
				body.rpc("update_health", -damage)
				body.rpc_id(body.name.to_int(), "set_knockback", force_vector / 1.5)
				#body.knockback = force_vector / 1.5
			if body.has_method("rpc_impulse"):
				print("rpc_impulse")
				if distance == 0:
					return
				body.rpc("rpc_impulse", force_vector)
	
	
func _on_delete_timer_timeout() -> void:
	queue_free()
