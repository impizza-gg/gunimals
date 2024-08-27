extends Control

@onready var NameLabel := $Player/NameLabel
@onready var Crown := $Player/Crown
@onready var KickButton := $Player/KickButton

var playerName : String = "Player"
var id : int = 0
var admin : bool = false
var show_controls : bool = true
var current_character := 0

func _enter_tree() -> void:
	set_multiplayer_authority(id)


func _ready() -> void:
	NameLabel.text = playerName
	Crown.visible = admin
	KickButton.visible = show_controls
	KickButton.disabled = not show_controls
	$Character/NextCharacter.visible = id == multiplayer.get_unique_id()
	$Character/BackCharacter.visible = id == multiplayer.get_unique_id()
	
	
func _on_kick_button_pressed() -> void:
	multiplayer.multiplayer_peer.disconnect_peer(id)


func _on_back_character_pressed() -> void:
	character_btn(-1)

	
func _on_next_character_pressed() -> void:
	character_btn()


func set_sprite(character: int) -> void:
	$Character/CharacterContainer/SelectCharacter.change_sprite_local(character)


func character_btn(val := 1) -> void:
	if not is_multiplayer_authority():
		return
		
	current_character += val
	var chars := Globals.CharacterArray.size()
	if current_character < 0:
		current_character = chars - 1
	elif current_character >= chars:
		current_character = 0

	$Character/CharacterContainer/SelectCharacter.rpc("change_sprite", current_character, id)
