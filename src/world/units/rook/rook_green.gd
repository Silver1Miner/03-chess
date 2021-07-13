extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/rook/piece-wu-che.png")
	west_sprite = preload("res://assets/pieces/rook/image_part_052.png")
	set_sprite_style()
	piece_type = "rook"
	team = "green"
	piece_name = piece_type + "_" + team
