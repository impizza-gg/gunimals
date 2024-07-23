extends Node2D


@rpc("any_peer", "call_local")
func playCountdown() -> void:
	$".".visible = true
	$CountdownPlayer.play("countdown")


func _on_countdown_player_animation_finished(_anim_name: StringName) -> void:
	Signals.unlock.emit()
	$".".visible = false
