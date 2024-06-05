extends Node2D

signal shoot(bullet: Node, location: Vector2)

@export var currentGunScene: PackedScene = preload("res://scenes/guns/example_gun/example_gun.tscn")
@onready var Player := $".."
var currentGun: Gun


func _ready() -> void:
	if currentGunScene.can_instantiate():
		currentGun = currentGunScene.instantiate()
		add_child(currentGun)


@rpc("any_peer", "call_remote")
func shoot_function(gun_position: Vector2, gun_rotation: float, direction: Vector2) -> void:
	if multiplayer.is_server():
		rpc("spawn_bullets", gun_position, gun_rotation, direction)


@rpc("any_peer", "call_local")
func spawn_bullets(gun_position: Vector2, gun_rotation: float, direction: Vector2) -> void:
	var bulletList : Array[Node] = currentGun.shoot(gun_position, gun_rotation, direction)
	for bullet in bulletList:
		add_child(bullet)


func _process(_delta: float) -> void:
	#currentGun.look_at(get_global_mouse_position())
	#var direction = Vector2.RIGHT.rotated(currentGun.rotation)
	if is_multiplayer_authority():
		var gunRotation = currentGun.global_position.angle_to_point(get_global_mouse_position())
		var direction = Vector2.from_angle(rotation)
		rotation = gunRotation
	
		if Input.is_action_just_pressed("shoot"):
			var gun_position := currentGun.global_position
			if multiplayer.is_server():
				shoot_function(gun_position, rotation, direction)
			else:
				rpc_id(1, "shoot_function", gun_position, rotation, direction)
