extends CharacterBody2D

@onready var Sprite := $Sprite2D
@onready var NameLabel := $Name
@onready var HealthBar := $HealthBar
@onready var GunManager := $GunManager

@export var max_health := 100.0
@export var speed := 300.0
@export var jump_velocity := -400.0

var current_health := max_health
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_name := "Player"
var locked := false
@onready var is_hovering := false
var interactables : Array[Node] = []
var pickables : Array[Node] = []

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int(), true)


func _ready() -> void:
	NameLabel.text = player_name
	HealthBar.max_value = max_health
	HealthBar.value = current_health
	
	if is_multiplayer_authority():
		var cameraScene := load("res://scenes/player/player_camera.tscn")
		var camera = cameraScene.instantiate()
		add_child(camera)


func _process(_delta: float) -> void:
	if not is_multiplayer_authority() or locked:
		return
	if Input.is_action_just_pressed("esc"):
		Signals.toggle_pause_menu.emit()
	if Input.is_action_just_pressed("move_left"):
		Sprite.flip_h = true
	elif Input.is_action_just_pressed("move_right"):
		Sprite.flip_h = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_multiplayer_authority() and not locked and not Signals.paused:			
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			
		if Input.is_action_just_pressed("interact") and interactables.size() > 0:
			if interactables[0].has_method("interact"):
				interactables[0].interact(self)
				
		if Input.is_action_just_pressed("pick_up") and pickables.size() > 0:
			if pickables[0].has_method("interact"):
				pickables[0].interact(self)
			
		if Input.is_action_just_pressed("drop"):
			GunManager.rpc("drop")
			
	move_and_slide()


#func is_interacting() -> bool:
	#return Input.is_action_just_pressed("pick_up")


@rpc("any_peer", "call_local")
func update_health(change: int) -> void:
	current_health += change
	current_health = min(current_health, max_health)
	HealthBar.value = current_health
	if current_health <= 0:
		death()


func death() -> void:
	locked = true
	GunManager.lock()


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if not is_multiplayer_authority():
		return
		
	if area.is_in_group("pickable"):
		pickables.append(area)
	else:
		interactables.append(area)
	if area.has_method("hover") and not is_hovering:
		area.hover()
		is_hovering = true


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if not is_multiplayer_authority():
		return
	
	if area.is_in_group("pickable"):
		pickables.erase(area)
	else:
		interactables.erase(area)
	if area.has_method("unhover"):
		area.unhover()
		is_hovering = false
		
