extends PathFollow2D

@export var speed := 200.0

func _ready() -> void:
	$Node2D/AnimationPlayer.play("rotate")

func _process(delta: float) -> void:
	progress += delta * speed
