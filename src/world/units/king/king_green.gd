extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/king/piece-wu.png")
	west_sprite = preload("res://assets/pieces/king/image_part_054.png")
	set_sprite_style()
	piece_type = "king"
	team = "green"
	piece_name = piece_type + "_" + team
