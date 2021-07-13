extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/knight/piece-wei-qi.png")
	west_sprite = preload("res://assets/pieces/knight/image_part_062.png")
	set_sprite_style()
	piece_type = "knight"
	team = "blue"
	piece_name = piece_type + "_" + team
