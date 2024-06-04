extends Control

@onready var NameLabel := $Label
@onready var Crown := $Crown
@onready var KickButton := $KickButton

var playerName : String = "Player"
var id : int = 0
var admin : bool = false
var show_controls : bool = true

func _ready() -> void:
	NameLabel.text = playerName
	Crown.visible = admin
	KickButton.visible = show_controls
	KickButton.disabled = not show_controls
	
	
func _on_kick_button_pressed() -> void:
	multiplayer.multiplayer_peer.disconnect_peer(id)
