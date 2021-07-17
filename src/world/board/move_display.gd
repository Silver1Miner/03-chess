extends TileMap
class_name UnitPath

export var grid: Resource = preload("res://src/world/board/Grid.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func draw_moves(cells: Array) -> void:
	clear_moves()
	for c in cells:
		set_cellv(c, 0)

func clear_moves() -> void:
	for c in get_used_cells():
		if get_cellv(c) == 0:
			set_cellv(c, -1)

func add_draw_attacked(cells: Array) -> void:
	for c in cells:
		set_cellv(c, 1)

func draw_attacked(cells: Array) -> void:
	clear_attacked()
	for c in cells:
		set_cellv(c, 1)

func clear_attacked() -> void:
	for c in get_used_cells():
		if get_cellv(c) == 1:
			set_cellv(c, -1)
