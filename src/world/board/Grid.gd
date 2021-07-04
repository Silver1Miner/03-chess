extends Resource
class_name Grid

export var board_size = Vector2(9, 9)
export var cell_size = Vector2(64, 64)
var _half_cell_size = cell_size/2

func calculate_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size

func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position/cell_size).floor()

func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out = cell_coordinates.x >= 0 and cell_coordinates.x < board_size.x
	return out and cell_coordinates.y >= 0 and cell_coordinates.y < board_size.y

func clamp(grid_position: Vector2) -> Vector2:
	var clamped_position := grid_position
	clamped_position.x = clamp(clamped_position.x, 0, board_size.x - 1.0)
	clamped_position.y = clamp(clamped_position.y, 0, board_size.y - 1.0)
	return clamped_position

# return 2d cell coordinate as 1d index
func as_index(cell: Vector2) -> int:
	return int(cell.x + board_size.x * cell.y)
