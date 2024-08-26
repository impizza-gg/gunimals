extends StaticBody2D

@export var max_health := 10000.0
@onready var current_health := max_health
@onready var Animations := $AnimationPlayer

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
	

@rpc("any_peer", "call_local")
func update_health(change: int):
	current_health += change
	current_health = min(current_health, max_health)
	Animations.play("damage")
	#HealthBar.value = current_health
