extends Node2D

signal shoot(bullet: Node, location: Vector2)

@export var CurrentGunScene: String = "res://scenes/guns/example_automatic/automatic_gun.tscn"

@onready var parent := get_parent()
@onready var ReloadBar := $"../ReloadBar"
@onready var ReloadTimer : Timer = $"../ReloadTimer"
@onready var locked := true

var current_gun: Gun

func _ready() -> void:
	if CurrentGunScene:
		equip_gun(CurrentGunScene)


func pre_equip():
	pass


func remove():
	lock()
	current_gun = null
	for child in get_children():
		if child is Gun:
			remove_child(child)


@rpc("any_peer", "call_local")
func equip_gun(gun_scene_path: String, clips = -1, ammo = -1) -> void:
	var gun_scene: PackedScene = load(gun_scene_path)
	print(clips)
	print(ammo)
	
	if gun_scene.can_instantiate():
		if current_gun:
			drop()
		current_gun = gun_scene.instantiate()
		CurrentGunScene = gun_scene_path
			
		ReloadTimer.wait_time = current_gun.reload_time
		ReloadTimer.one_shot = true
		if ReloadTimer.timeout.is_connected(reload):
			ReloadTimer.timeout.disconnect(reload)
		ReloadTimer.timeout.connect(reload)
		
		add_child(current_gun)
		
		if clips > -1:
			current_gun.clips = clips
		if ammo > -1:
			current_gun.current_ammo = ammo
			
		if is_multiplayer_authority():
			#print(current_gun.current_ammo)
			current_gun.updateHUD()
			Signals.set_hud_visibility.emit(true)
			Signals.set_clip_label_visibility.emit(current_gun.reloadable)
	print(current_gun)
	if not locked:
		current_gun.locked = false
	
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


@rpc("any_peer", "call_local")
func drop() -> void:
	if not current_gun:
		return
		
	var pick_up := current_gun.PickUpScene.instantiate()
	pick_up.item_scene = CurrentGunScene
	pick_up.clips = current_gun.clips
	pick_up.current_ammo = current_gun.current_ammo
	pick_up.global_position = global_position
	parent.get_parent().add_child(pick_up)
	
	current_gun = null
	for child in get_children():
		if child is Gun:
			remove_child(child)
			
	if is_multiplayer_authority():
		Signals.set_hud_visibility.emit(false)
