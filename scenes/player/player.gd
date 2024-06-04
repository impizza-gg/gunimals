extends CharacterBody2D

@onready var Sprite := $Sprite2D
@onready var NameLabel := $Name
const SPEED := 300.0
const JUMP_VELOCITY := -400.0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_name := "Player"

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int(), true)


func _ready() -> void:
	NameLabel.text = player_name
	if is_multiplayer_authority():
		var cameraScene := load("res://scenes/player/player_camera.tscn")
		var camera = cameraScene.instantiate()
		add_child(camera)


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		move_and_slide() # confuso
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("move_left"):
		Sprite.flip_h = true
	elif Input.is_action_just_pressed("move_right"):
		Sprite.flip_h = false
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
