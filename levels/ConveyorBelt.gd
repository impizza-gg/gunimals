extends StaticBody2D

@export var speed := -200.0

func _ready() -> void:
	constant_linear_velocity.x = speed
	$AnimationPlayer.play("conveyor_belt")

func _process(_delta: float) -> void:
	pass
