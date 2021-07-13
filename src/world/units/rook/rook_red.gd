extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/rook/piece-shu-che.png")
	west_sprite = preload("res://assets/pieces/rook/image_part_034.png")
	set_sprite_style()
	piece_type = "rook"
	team = "red"
	piece_name = piece_type + "_" + team
