extends HBoxContainer

@onready var sprite : AnimatedSprite2D = $Control/AnimatedSprite2D
@onready var text_label : Label = $Name
@onready var points_label : Label = $Points

func _ready() -> void:
	sprite.play("idle")
	
	
func set_data(data: Dictionary, is_winner = false) -> void:
	print(data)
	text_label.text = data["player_name"]
	change_sprite(data["character"])
	set_points(data["points"])
	if is_winner:
		winner()
	
	
func winner() -> void:
	text_label.self_modulate = Color(1., 1.0, 0.4)
	points_label.self_modulate = Color(1., 1.0, 0.4)
	
	
func change_sprite(type: int) -> void:
	var path = Globals.CharacterArray[type]
	var sp_frames = load(path)
	sprite.sprite_frames = sp_frames
	sprite.play("idle")


func set_points(points: int) -> void:
	points_label.text = str(points)
