extends Gun

var rng := RandomNumberGenerator.new()

func create_bullets(initial_position: Vector2, _bullet_rotation: float, direction: Vector2) -> Array[Node]:
	var bulletList : Array[Node] = []
	for i in bullet_num:
		var bullet := projectile.instantiate()
		# essa lógica poderia ser passada para o próprio projetil, mas não sei o que é melhor agora
		bullet.position = initial_position
		#bullet.rotation = bullet_rotation
		bullet.rotation = direction.angle()
		var random_factor := rng.randf_range(-0.15, 0.15)
		direction.y += random_factor
		direction.y = clamp(direction.y, -1, 1)
		bullet.direction = direction 
		bulletList.append(bullet)
	return bulletList
