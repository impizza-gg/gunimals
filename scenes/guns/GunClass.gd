class_name Gun extends Node2D

signal update_ui(current_ammo: int)

@export var offset_x := 20.0
@export var offset_y := 0.0
@export var projectile : PackedScene = preload("res://scenes/guns/example_projectile.tscn")
@export var max_ammo := 200
@export var bullet_num := 1
@export var damage := 25
@export var automatic := false
@export var cooldown := 0.5

@export var ShootPlayer: AudioStreamPlayer
@export var NoAmmoPlayer: AudioStreamPlayer

@onready var current_ammo := max_ammo

func _ready() -> void:
	position += Vector2(offset_x, offset_y)
	

# função da classe que é igual para todas as armas
func shoot(initial_position: Vector2, bullet_rotation: float, direction: Vector2, owner_id: int) -> Array[Node]:
	if current_ammo == 0:
		if NoAmmoPlayer:
			NoAmmoPlayer.play()
		return []
	else: 
		current_ammo -= 1
		if ShootPlayer:
			ShootPlayer.play()
		return create_bullets(initial_position, bullet_rotation, direction, owner_id)
	

# função que deve ser sobrescrita pela arma
func create_bullets(initial_position: Vector2, bullet_rotation: float, direction: Vector2, owner_id: int) -> Array[Node]:
	var bullet := projectile.instantiate()
	bullet.position = initial_position
	bullet.rotation = bullet_rotation
	bullet.direction = direction
	bullet.owner_id = owner_id
	bullet.damage = damage
	var bulletList : Array[Node] = [bullet]
	return bulletList
