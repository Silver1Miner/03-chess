extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/rook/piece-wei-sheng.png")
	west_sprite = preload("res://assets/pieces/rook/image_part_064.png")
	set_sprite_style()
	piece_type = "rook"
	team = "blue"
	piece_name = piece_type + "_" + team
