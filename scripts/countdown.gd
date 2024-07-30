extends Node2D


@rpc("any_peer", "call_local")
func playCountdown() -> void:
	$Countdown.text = ""
	$CountdownPlayer.play("countdown")
	$".".visible = true


func _on_countdown_player_animation_finished(_anim_name: StringName) -> void:
	Signals.unlock.emit()
	$".".visible = false
