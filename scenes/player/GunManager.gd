extends Node2D

signal shoot(bullet: Node, location: Vector2)

@export var currentGunScene: PackedScene = preload("res://scenes/guns/example_gun/example_gun.tscn")
@onready var Player := $".."
var currentGun: Gun


func _ready() -> void:
	if currentGunScene.can_instantiate():
		currentGun = currentGunScene.instantiate()
		add_child(currentGun)


func shoot_function(direction: Vector2) -> void:
	#var bullet = currentGun.projectile.instantiate()
	#bullet.position = currentGun.global_position
	#bullet.rotation = currentGun.rotation
	#bullet.direction = direction
	#Player.get_parent().add_child(bullet)
	
	var bulletList : Array[Node] = currentGun.shoot(currentGun.global_position, currentGun.rotation, direction)
	for bullet in bulletList:
		add_child(bullet)

func _process(_delta: float) -> void:
	var gunRotation = currentGun.global_position.angle_to_point(get_global_mouse_position())
	rotation = gunRotation
	var direction = Vector2.from_angle(rotation)
	#currentGun.look_at(get_global_mouse_position())
	#var direction = Vector2.RIGHT.rotated(currentGun.rotation)
	
	if Input.is_action_just_pressed("shoot"):
		shoot_function(direction)
