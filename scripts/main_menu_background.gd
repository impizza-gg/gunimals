extends Node2D

@onready var path : PathFollow2D = $Path2D/PathFollow2D
var flipped = false

func _process(delta: float) -> void:
	path.progress += delta * 125
	if not flipped and path.progress_ratio > 0.4:
		flipped = true
		$Path2D/PathFollow2D/Cat.flip_h = true
		$Path2D/PathFollow2D/Frog.flip_h = true
		$Path2D/PathFollow2D/Duck.flip_h = true
		$Path2D/PathFollow2D/Penguin.flip_h = true
	if flipped and path.progress_ratio < 0.4:
		flipped = false
		$Path2D/PathFollow2D/Cat.flip_h = false
		$Path2D/PathFollow2D/Frog.flip_h = false
		$Path2D/PathFollow2D/Duck.flip_h = false
		$Path2D/PathFollow2D/Penguin.flip_h = false
