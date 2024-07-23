extends Node2D

@rpc("any_peer", "call_local")
func playTransition(backwards := false) -> void:
	$".".visible = true
	if backwards:
		$TransitionPlayer.play_backwards("transition")
	else:
		$TransitionPlayer.play("transition")
