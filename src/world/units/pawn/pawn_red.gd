extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/pawn/piece-shu-bing.png")
	west_sprite = preload("res://assets/pieces/pawn/image_part_031.png")
	set_sprite_style()
	piece_type = "pawn"
	team = "red"
	piece_name = piece_type + "_" + team
