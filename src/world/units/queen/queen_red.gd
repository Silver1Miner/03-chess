extends Unit

func _ready():
	east_sprite = preload("res://assets/pieces/queen/piece-shu-shuai.png")
	west_sprite = preload("res://assets/pieces/queen/image_part_035.png")
	set_sprite_style()
	piece_type = "queen"
	team = "red"
	piece_name = piece_type + "_" + team
