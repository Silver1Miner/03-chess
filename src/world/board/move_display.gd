extends TileMap
class_name UnitPath

export var grid: Resource = preload("res://src/world/board/Grid.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func draw(cells) -> void:
	clear()
	for c in cells:
		set_cellv(c, 0)
