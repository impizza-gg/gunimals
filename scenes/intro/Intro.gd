extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("Fade_In")
	
	var tree := get_tree()
	var main_scene = load("res://scenes/main_scene.tscn")
	await tree.create_timer(4).timeout
	
	# trocar o fade_out para main_scene para ficar mais suave
	$AnimationPlayer.play("Fade_Out")
	await tree.create_timer(3).timeout	
	tree.change_scene_to_packed(main_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
