extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/pawn/piece-wu-zu.png")
	west_sprite = preload("res://assets/pieces/pawn/image_part_049.png")
	set_sprite_style()
	piece_type = "pawn"
	team = "green"
	piece_name = piece_type + "_" + team
