extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/queen/piece-wu-du.png")
	west_sprite = preload("res://assets/pieces/queen/image_part_053.png")
	set_sprite_style()
	piece_type = "queen"
	team = "green"
	piece_name = piece_type + "_" + team
