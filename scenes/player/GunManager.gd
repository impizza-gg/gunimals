extends Node2D

signal shoot(bullet: Node, location: Vector2)

@export var CurrentGunScene: String = "res://scenes/guns/example_automatic/automatic_gun.tscn"
@onready var parent := get_parent()
@onready var ReloadBar := $"../ReloadBar"
@onready var ReloadTimer : Timer = $"../ReloadTimer"
@onready var locked := false

var current_gun: Gun

func _ready() -> void:
	equip_gun(CurrentGunScene)


@rpc("any_peer", "call_local")
func equip_gun(gun_scene_path: String) -> void:
	var gun_scene: PackedScene = load(gun_scene_path)
	
	if gun_scene.can_instantiate():
		if current_gun:
			current_gun.free()
		current_gun = gun_scene.instantiate()
		
		ReloadTimer.wait_time = current_gun.reload_time
		ReloadTimer.one_shot = true
		if ReloadTimer.timeout.is_connected(reload):
			ReloadTimer.timeout.disconnect(reload)
		ReloadTimer.timeout.connect(reload)
		
		add_child(current_gun)
		
		if is_multiplayer_authority():
			current_gun.updateHUD()
			Signals.set_hud_visibility.emit(true)
			Signals.set_clip_label_visibility.emit(current_gun.reloadable)


func reload() -> void:
	current_gun.rpc("reload")
	#current_gun.reload()
	ReloadBar.visible = false


func lock() -> void:
	locked = true
	if current_gun:
		current_gun.locked = true


func _process(_delta: float) -> void:
	#current_gun.look_at(get_global_mouse_position())
	#var direction = Vector2.RIGHT.rotated(current_gun.rotation)
	if locked:
		return
		
	if is_multiplayer_authority():
			
		if not current_gun:
			return
			
		if Input.is_action_just_pressed("reload"):
			if current_gun.can_reload():
				ReloadTimer.start()
				current_gun.reloading = true
				ReloadBar.visible = true
			
		if current_gun.reloading:
			ReloadBar.value = (ReloadTimer.time_left / current_gun.reload_time) * 100.0
			
		var gunRotation = global_position.angle_to_point(get_global_mouse_position())
		rotation = gunRotation

