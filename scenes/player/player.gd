extends CharacterBody2D

#@onready var Sprite := $Sprite2D
@onready var NameLabel := $Name
@onready var HealthBar := $HealthBar
@onready var GunManager := $GunManager
@onready var Sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var knockback := Vector2.ZERO

@export var max_health := 100.0
@export var speed := 300.0
@export var jump_velocity := -500.0

var current_health := max_health
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_name := "Player"
var locked := true
var dead := false
@onready var is_hovering := false
var interactables : Array[Node] = []
var pickables : Array[Node] = []
var character := -1
var canDoubleJump := false
var doubleJumpUsed := false
var canDash := false
var isDashing := false
var dashUsed := false
var dashSpeed := Vector2.ZERO
var canGlide := false
var character_type := 0
var dash_timer := Timer.new()
const DASH_DURATION := 0.25
var camera = null
var gravity_factor := 1.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int(), true)
	

func _ready() -> void:
	NameLabel.text = player_name
	HealthBar.max_value = max_health
	HealthBar.value = current_health
	gravity *= gravity_factor
	Signals.unlock.connect(unlock)
	dash_timer.wait_time = DASH_DURATION
	dash_timer.one_shot = true
	dash_timer.connect("timeout", _on_timer_timeout)
	add_child(dash_timer)
	
	if character_type == Globals.Characters.PENGUIN:
		canDoubleJump = true
	if character_type == Globals.Characters.CAT:
		canDash = true
	if character_type == Globals.Characters.FROG:
		jump_velocity = -750.0
	if character_type == Globals.Characters.DUCK:
		canGlide = true
	
	# não tem segurança nenhuma hahahahahahahhaha
	var path = Globals.CharacterArray[character_type]
	Sprite.sprite_frames = load(path)
	
	if is_multiplayer_authority():
		var cameraScene := load("res://scenes/player/player_camera.tscn")
		camera = cameraScene.instantiate()
		add_child(camera)
		camera.make_current()


func _process(_delta: float) -> void:
	#$AnimatedSprite2D.position = lerp($AnimatedSprite2D.position, position, 0.4) + Vector2(1, -13)
	
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
		dashUsed = false
		
	if not is_on_floor():
		velocity.y += gravity * delta
	if not is_on_floor() and canGlide and Input.is_action_pressed("jump") and velocity.y > 0:
		velocity.y = 70
		
	if locked or Signals.paused:
		if isDashing:
			Sprite.play("dash")
			velocity = dashSpeed
			dashUsed = true
		#else:
			#velocity = Vector2.ZERO
		
	if not locked and not Signals.paused: 
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			if Input.is_action_just_pressed("dash") and not dashUsed:
				isDashing = true
				dashUsed = true
				dashSpeed = Vector2(1000 * direction, 0)
				dash_timer.start()
				Sprite.play("dash")
				locked = true
			else:
				velocity.x = direction * speed
				if GunManager.current_gun and GunManager.current_gun.slows_down:
					velocity.x += -direction * GunManager.current_gun.slow_down_factor
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = jump_velocity
				if GunManager.current_gun and GunManager.current_gun.slows_down:
					velocity.y += GunManager.current_gun.slow_down_factor
			else:
				if canDoubleJump and not doubleJumpUsed:
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
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	velocity += knockback
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	if knockback.x > -0.1 and knockback.x < 0.1:
		knockback.x = 0
	if knockback.y > -0.1 and knockback.y < 0.1:
		knockback.y = 0
	
	move_and_slide()


func unlock() -> void:
	locked = false
	GunManager.locked = false
	if GunManager.current_gun:
		GunManager.current_gun.locked = false


@rpc("any_peer", "call_local")
func update_health(change: int) -> void:
	if locked: 
		return
	current_health += change
	current_health = min(current_health, max_health)

	HealthBar.value = current_health
	if change < 0:
		Sprite.play("hurt")
	if current_health <= 0:
		death()


func death(play_animation = true) -> void:
	locked = true
	dead = true
	
	if play_animation:
		Sprite.play("death")
	$HealthBar.visible = false
	$ReloadBar.visible = false
	
	dashSpeed = Vector2.ZERO
	isDashing = false
	
	$Name.self_modulate = Color(1, 0, 0, 0.5)

	if is_multiplayer_authority():
		Signals.set_hud_visibility.emit(false)
	if multiplayer.is_server():
		Signals.player_death.emit(name.to_int())

	
	for interactable in interactables:
		if interactable.has_method("unhover"):
			interactable.unhover()
	
	for pickable in pickables:
		if pickable.has_method("unhover"):
			pickable.unhover()
			
	interactables.clear()
	pickables.clear()
	GunManager.call_deferred("drop")
	GunManager.lock()


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if (not is_multiplayer_authority()) or dead:
		return

	if area.is_in_group("pickable"):
		pickables.append(area)
	elif area.is_in_group("interactable"):
		interactables.append(area)
		
	if area.has_method("hover") and not is_hovering:
		area.hover()
		is_hovering = true


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if not is_multiplayer_authority():
		return
	
	if area.is_in_group("pickable"):
		pickables.erase(area)
	elif area.is_in_group("interactable"):
		interactables.erase(area)
		
	if area.has_method("unhover"):
		area.unhover()
		is_hovering = false


func _on_timer_timeout() -> void:
	isDashing = false
	locked = false
	velocity.x = 0


@rpc("any_peer", "call_local")
func change_camera() -> void:
	var level = get_parent().level
	print(level)
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
			velocity = Vector2.ZERO
			gravity = 0


@rpc("any_peer", "call_local")
func set_knockback(kb: Vector2) -> void:
	knockback = kb


@rpc("any_peer", "call_local")
func flatten() -> void:
	death(false)
	$AnimationPlayer.play("flatten")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "flatten":
		$AnimatedSprite2D.pause()
