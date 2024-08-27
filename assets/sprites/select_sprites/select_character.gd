extends Node2D

@onready var Sprite : AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	Sprite.play("idle")


func change_sprite_local(type: int) -> void:
	var path = Globals.CharacterArray[type]
	var sp_frames = load(path)
	Sprite.sprite_frames = sp_frames
	Sprite.play("idle")


@rpc("any_peer", "call_local")
func change_sprite(type: int, id: int) -> void:
	var path = Globals.CharacterArray[type]
	var sp_frames = load(path)
	Sprite.sprite_frames = sp_frames
	Sprite.play("idle")
	
	if multiplayer.is_server():
		Signals.change_player_character.emit(type, id)
