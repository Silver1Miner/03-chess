extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/pawn/piece-wei-bu.png")
	west_sprite = preload("res://assets/pieces/pawn/image_part_061.png")
	set_sprite_style()
	piece_type = "pawn"
	team = "blue"
	piece_name = piece_type + "_" + team
