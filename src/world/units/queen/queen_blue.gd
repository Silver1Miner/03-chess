extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/queen/piece-wei-jiang.png")
	west_sprite = preload("res://assets/pieces/queen/image_part_065.png")
	set_sprite_style()
	piece_type = "queen"
	team = "blue"
	piece_name = piece_type + "_" + team
