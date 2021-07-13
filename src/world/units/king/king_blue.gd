extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/king/piece-wei.png")
	west_sprite = preload("res://assets/pieces/king/image_part_066.png")
	set_sprite_style()
	piece_type = "king"
	team = "blue"
	piece_name = piece_type + "_" + team
