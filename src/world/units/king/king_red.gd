extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/king/piece-shu.png")
	west_sprite = preload("res://assets/pieces/king/image_part_036.png")
	set_sprite_style()
	piece_type = "king"
	team = "blue"
	piece_name = piece_type + "_" + team
