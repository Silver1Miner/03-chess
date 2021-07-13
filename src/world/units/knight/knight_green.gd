extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/knight/piece-wu-ma.png")
	west_sprite = preload("res://assets/pieces/knight/image_part_050.png")
	set_sprite_style()
	piece_type = "knight"
	team = "green"
	piece_name = piece_type + "_" + team
