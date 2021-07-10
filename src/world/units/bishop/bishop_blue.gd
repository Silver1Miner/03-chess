extends Bishop

# Called when the node enters the scene tree for the first time.
func _ready():
	east_sprite = preload("res://assets/pieces/bishop/piece-wei-xiang.png")
	west_sprite = preload("res://assets/pieces/bishop/image_part_051.png")
	set_sprite_eastern()
