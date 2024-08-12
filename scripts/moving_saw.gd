extends Node2D

var moving := true
var direction := true

@export var speed := -200.0
@onready var use_speed := speed
@onready var path := $Path2D/PathFollow2D

func _ready() -> void:
	$Path2D/PathFollow2D/Node2D/AnimationPlayer.play("rotate")
	
	
func _process(delta: float) -> void:
	path.progress += delta * use_speed


@rpc("any_peer", "call_local")
func interact() -> void:
	print("interacting with moving saw")
	if moving:
		moving = not moving
	else:
		direction = not direction
		moving = true
	
	if moving:
		if direction:
			use_speed = speed
			$Path2D/PathFollow2D/Node2D/AnimationPlayer.play()
		else:
			use_speed = -speed
			$Path2D/PathFollow2D/Node2D/AnimationPlayer.play()
	else:
		use_speed = 0
		$Path2D/PathFollow2D/Node2D/AnimationPlayer.pause()
