extends Node2D

@onready var CooldownTimer := $"../Cooldown"

@rpc("any_peer", "call_local")
func interact(_user: Node) -> void:
	if not CooldownTimer.is_stopped():
		print("button is in cooldown")
		return
	var path = "../" + $"..".interact_with
	var object = get_node_or_null(path)
	$"../AudioStreamPlayer".pitch_scale = randf_range(0.5, 0.7)
	$"../AudioStreamPlayer".play()
	CooldownTimer.start()
	$"../ButtonSprite".play("pressed")
	if object != null and object.has_method("interact"):
		#object.rpc("interact")
		object.interact()


func hover() -> void:
	$"../Label".visible = true
	
	
func unhover() -> void:
	$"../Label".visible = false
