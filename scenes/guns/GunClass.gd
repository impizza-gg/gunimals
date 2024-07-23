class_name Gun extends Node2D

signal update_ui(current_ammo: int)

@export var offset_x := 20.0
@export var offset_y := 0.0
@export var projectile : PackedScene = preload("res://scenes/guns/example_projectile.tscn")
@export var max_ammo := 200
@export var max_clips := 1
@export var bullet_num := 1
@export var damage := 25
@export var automatic := false
@export var reloadable := true
@export var cooldown := 0.2
@export var reload_time := 1
@export var ShootPlayer: AudioStreamPlayer
@export var NoAmmoPlayer: AudioStreamPlayer
@export var ReloadPlayer : AudioStreamPlayer
@export var drop_shells := true
@export var ShootSound : AudioStream
@export var knockback_x := 0.0
@export var knockback_y := 0.0
@export var knocks_back := false
@export var vary_pitch := true
@export var PickUpScene := preload("res://scenes/pickupables/default_pickup/default_pickup.tscn")

@onready var CooldownTimer := Timer.new()
@onready var Shell := preload("res://scenes/shell/shell.tscn")

@onready var locked := true
@onready var player := get_parent().get_parent()
@onready var my_id := player.name.to_int()
@onready var clips := max_clips
@onready var current_ammo := max_ammo
@onready var reloading := false

func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().get_parent().name.to_int())


func _ready() -> void:
	position += Vector2(offset_x, offset_y)
	CooldownTimer.wait_time = cooldown
	CooldownTimer.one_shot = true
	add_child(CooldownTimer)


func updateHUD() -> void:
	if is_multiplayer_authority():
		Signals.update_hud_ammo_current.emit(current_ammo)
		Signals.update_hud_ammo_max.emit(max_ammo)
		Signals.update_hud_clip_current.emit(clips)


# função da classe que é igual para todas as armas
func shoot(initial_position: Vector2, bullet_rotation: float, direction: Vector2, owner_id: int) -> Array[Node]:
	if current_ammo == 0:
		if NoAmmoPlayer:
			NoAmmoPlayer.play()
		return []
	else: 
		current_ammo -= 1
		if ShootPlayer:
			if vary_pitch:
				var p_scale := randf_range(0.9, 1.1)
				ShootPlayer.pitch_scale = p_scale
			ShootPlayer.play()
		return create_bullets(initial_position, bullet_rotation, direction, owner_id)
	

# função que deve ser sobrescrita pela arma
func create_bullets(initial_position: Vector2, bullet_rotation: float, direction: Vector2, owner_id: int) -> Array[Node]:
	var bullet := projectile.instantiate()
	
	if knocks_back:
		#var dir_factor = direction.x / abs(direction.x)
		#var y_factor := randf_range(-15.0, 25.0)
		#var x_factor := randf_range(15.5, 25.0)
		#player.knockback = -Vector2(dir_factor * x_factor, y_factor)
		#player.knockback.y = player.knockback.y / 10
		#player.knockback = -Vector2(dir_factor * knockback_x, knockback_y)
		player.knockback = -direction * Vector2(knockback_x, knockback_y)
	
	bullet.position = initial_position
	bullet.rotation = bullet_rotation
	bullet.direction = direction
	bullet.owner_id = owner_id
	bullet.damage = damage
	var bulletList : Array[Node] = [bullet]
	return bulletList


# talvez seja ok tirar essa funcao
@rpc("authority", "call_remote")
func shoot_function(gun_position: Vector2, gun_rotation: float, owner_id: int) -> void:
	if multiplayer.is_server():
		rpc("spawn_bullets", gun_position, gun_rotation, owner_id)


@rpc("any_peer", "call_local")
func spawn_bullets(gun_position: Vector2, gun_rotation: float, owner_id: int) -> void:
	var direction := Vector2.from_angle(gun_rotation)
	var bullet_list : Array[Node] = shoot(gun_position, gun_rotation, direction, owner_id)
	if is_multiplayer_authority():
		Signals.update_hud_ammo_current.emit(current_ammo)
	for bullet in bullet_list:
		get_parent().add_child(bullet)
	if bullet_list.size() > 0 and drop_shells:
		var shell := Shell.instantiate()
		shell.global_position = gun_position - Vector2(10, 5)
		shell.direction = direction
		get_parent().add_child(shell)


func can_reload() -> bool:
	return reloadable and clips > 0
	

@rpc("any_peer", "call_local")
func reload(reset := false) -> void:
	current_ammo = max_ammo
	if reset: 
		clips = max_clips
	else:
		clips -= 1
	if ReloadPlayer:
		ReloadPlayer.play()
	updateHUD()
	reloading = false


func _process(_delta: float) -> void:
	if not is_multiplayer_authority() or Signals.paused or locked:
		return
	
	#var gun_rotation = global_position.angle_to_point(get_global_mouse_position())
	var gun_rotation = get_parent().rotation
	
	# ta meio grande
	var should_shoot = ((automatic and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) or \
					   (not automatic and Input.is_action_just_pressed("shoot"))) and not reloading

	if should_shoot and CooldownTimer.is_stopped():
		#rpc("spawn_bullets", global_position, gun_rotation, direction, my_id)
		if multiplayer.is_server():
			shoot_function(global_position, gun_rotation, my_id)
		else:
			rpc_id(1, "shoot_function", global_position, gun_rotation, my_id)
			#rpc("spawn_bullets", global_position, gun_rotation, direction, my_id)
		CooldownTimer.start()
