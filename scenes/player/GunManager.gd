extends Node2D

signal shoot(bullet: Node, location: Vector2)

@export var CurrentGunScene: PackedScene = preload("res://scenes/guns/example_automatic/automatic_gun.tscn")

@onready var ShotgunScene := preload("res://scenes/guns/shotgun/shotgun.tscn")
@onready var ReloadBar := $"../ReloadBar"
@onready var ReloadTimer := $"../ReloadTimer"
var current_gun: Gun

func _ready() -> void:
	equip_gun(CurrentGunScene)


func equip_gun(gunScene: PackedScene) -> void:
	if gunScene.can_instantiate():
		if current_gun:
			current_gun.free()
		current_gun = gunScene.instantiate()
		
		ReloadTimer.wait_time = current_gun.reload_time
		ReloadTimer.one_shot = true
		ReloadTimer.timeout.connect(reload)
		
		add_child(current_gun)
		current_gun.updateHUD()
		Signals.set_hud_visibility.emit(true)
		Signals.set_clip_label_visibility.emit(current_gun.reloadable)


func reload() -> void:
	current_gun.rpc("reload")
	#current_gun.reload()
	ReloadBar.visible = false


func _process(_delta: float) -> void:
	#current_gun.look_at(get_global_mouse_position())
	#var direction = Vector2.RIGHT.rotated(current_gun.rotation)
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("change_weapon"):
			equip_gun(ShotgunScene)
			return
			
		if not current_gun:
			return
			
		if Input.is_action_just_pressed("reload"):
			if current_gun.can_reload():
				ReloadTimer.start()
				current_gun.reloading = true
				ReloadBar.visible = true
			
		if current_gun.reloading:
			ReloadBar.value = (ReloadTimer.time_left / current_gun.reload_time) * 100.0
			
		var gunRotation = current_gun.global_position.angle_to_point(get_global_mouse_position())
		rotation = gunRotation

