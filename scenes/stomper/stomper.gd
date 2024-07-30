extends Node2D

var active := false
@onready var animations : AnimationPlayer = $AnimationPlayer
@onready var Cooldown : Timer = $Cooldown

func _ready() -> void:
	Cooldown.timeout.connect(cooldown_end)


func cooldown_end() -> void:
	active = false


func _physics_process(_delta: float) -> void:
	if not active:
		var obj = $RayCast2D.get_collider()
		if obj:
			animations.play("stomp")
			active = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if active:
		if body.has_method("flatten"):
			body.flatten()
		if body.has_method("update_health"):
			body.update_health(-999.0)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stomp":
		animations.play("return")
	elif anim_name == "return":
		Cooldown.start()
