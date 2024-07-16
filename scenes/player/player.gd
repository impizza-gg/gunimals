extends CharacterBody2D

#@onready var Sprite := $Sprite2D
@onready var NameLabel := $Name
@onready var HealthBar := $HealthBar
@onready var GunManager := $GunManager
@onready var Sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var knockback := Vector2.ZERO

@export var max_health := 100.0
@export var speed := 300.0
@export var jump_velocity := -400.0

var current_health := max_health
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_name := "Player"
var locked := false
var dead := false
@onready var is_hovering := false
var interactables : Array[Node] = []
var pickables : Array[Node] = []
var character := ""
var canDoubleJump := false
var doubleJumpUsed := false
var canDash := false
var canGlide := false


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int(), true)
	

func _ready() -> void:
	NameLabel.text = player_name
	HealthBar.max_value = max_health
	HealthBar.value = current_health
	
	if Sprite.sprite_frames.resource_path.contains("pingu"):
		character = "pingu"
		canGlide = true
	if Sprite.sprite_frames.resource_path.contains("gato"):
		character = "gato"
		canDash = true
	if Sprite.sprite_frames.resource_path.contains("sapo"):
		character = "sapo"
		jump_velocity = -800.0
	if Sprite.sprite_frames.resource_path.contains("pato"):
		character = "pato"
		canDoubleJump = true
	
	if is_multiplayer_authority():
		var cameraScene := load("res://scenes/player/player_camera.tscn")
		var camera = cameraScene.instantiate()
		add_child(camera)
		camera.make_current()


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
	if not is_multiplayer_authority():
		move_and_slide()
		return
		
	if is_on_floor():
		doubleJumpUsed = false
		
	if not is_on_floor():
		velocity.y += gravity * delta
	if not is_on_floor() and canGlide and Input.is_action_pressed("jump"):
		velocity.y = 50
		
	if locked or Signals.paused:
		velocity = Vector2.ZERO
		
	velocity += knockback
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	if not locked and not Signals.paused: 
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
		if Input.is_action_just_pressed("jump") and not is_on_floor() and canDoubleJump and not doubleJumpUsed:
			velocity.y = jump_velocity
			doubleJumpUsed = true
		
		if direction != 0 and is_on_floor():
			Sprite.play("walk")
		elif velocity.y < -200:
			Sprite.play("jump")
		elif velocity.y > 0:
			Sprite.play("fall")
		elif velocity.x == 0 and velocity.y == 0:
			Sprite.play("idle")
			
		if Input.is_action_just_pressed("interact") and interactables.size() > 0:
			if interactables[0].has_method("interact"):
				interactables[0].interact(self)
				
		if Input.is_action_just_pressed("pick_up") and pickables.size() > 0:
			if pickables[0].has_method("interact"):
				pickables[0].interact(self)
			
		if Input.is_action_just_pressed("drop"):
			GunManager.rpc("drop")

	#print(knockback)
	if knockback.x > -0.1 and knockback.x < 0.1:
		knockback.x = 0
	if knockback.y > -0.1 and knockback.y < 0.1:
		knockback.y = 0
		
	move_and_slide()


#func is_interacting() -> bool:
	#return Input.is_action_just_pressed("pick_up")


@rpc("any_peer", "call_local")
func update_health(change: int) -> void:
	if locked: 
		return
	current_health += change
	current_health = min(current_health, max_health)
	HealthBar.value = current_health
	if current_health <= 0:
		Sprite.play("death")
		death()


func death() -> void:
	locked = true
	dead = true
	GunManager.call_deferred("drop")
	GunManager.lock()
	
	$HealthBar.visible = false
	$ReloadBar.visible = false
	$Name.self_modulate = Color(1, 0, 0, 0.5)
	
	if is_multiplayer_authority():
		Signals.set_hud_visibility.emit(false)
	if multiplayer.is_server():
		Signals.player_death.emit(name.to_int())


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if not is_multiplayer_authority() or dead:
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


@rpc("any_peer", "call_local")
func change_camera() -> void:
	var level = get_parent().level
	if level:
		var center = level.get_node("Center")
		GunManager.remove()
		$AnimatedSprite2D.visible = false
		$GunManager.visible = false
		$HealthBar.visible = false
		$Name.visible = false
		
		$CollisionShape2D.set_deferred("disabled", true)
		$InteractionArea.set_deferred("monitoring", false)
		if is_multiplayer_authority():
			position = center.position
		

@rpc("any_peer", "call_local")
func set_knockback(kb: Vector2) -> void:
	knockback = kb
