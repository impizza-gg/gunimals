extends StaticBody2D

@export var speed := -200.0
var state := 1

func _ready() -> void:
	constant_linear_velocity.x = speed
	$AnimationPlayer.play("conveyor_belt")

func _process(_delta: float) -> void:
	pass


@rpc("any_peer", "call_local")
func interact() -> void:
	#print("interacting with conveyor belt")
	state += 1
	if state > 1:
		state = -1
	
	if state == -1:
		constant_linear_velocity.x = -speed
		$AnimationPlayer.play_backwards("conveyor_belt")
	elif state == 1:
		constant_linear_velocity.x = speed
		$AnimationPlayer.play("conveyor_belt")
	else:
		constant_linear_velocity.x = 0
		$AnimationPlayer.pause()
