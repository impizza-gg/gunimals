extends RigidBody2D

@onready var ReleaseTimer := $Timer
@onready var ReleasePlayer := $AnimationPlayer
var direction := Vector2(1, 0)
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rotation = randf_range(-0.1, 0.1)
	var rand_factor := Vector2(randf_range(-100.0, 100.0), randf_range(-80.0, 80.0))
	var dir_factor = -(direction.x / abs(direction.x))
	apply_impulse(Vector2(300.0 * dir_factor, 100.0) + rand_factor)
	ReleaseTimer.timeout.connect(delete_shell)


func _process(_delta: float) -> void:
	pass


func delete_shell() -> void:
	ReleasePlayer.play("delete")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
