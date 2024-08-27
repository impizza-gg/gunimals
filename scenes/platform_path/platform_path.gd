extends Node2D

@export var speed := 200.0
@onready var path : PathFollow2D = $Path2D/PathFollow2D

#func _process(delta: float) -> void:
	#path.progress += delta * speed
