extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/knight/piece-shu-ma.png")
	west_sprite = preload("res://assets/pieces/knight/image_part_032.png")
	set_sprite_style()
	piece_type = "knight"
	team = "red"
	piece_name = piece_type + "_" + team
