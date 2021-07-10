extends Bishop

# Called when the node enters the scene tree for the first time.
func _ready():
	east_sprite = preload("res://assets/pieces/bishop/piece-shu-xiang.png")
	west_sprite = preload("res://assets/pieces/bishop/image_part_033.png")
	set_sprite_eastern()
