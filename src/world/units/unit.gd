extends Node2D
class_name Unit
# Unit: position, piece type, team

export var east_sprite = preload("res://assets/pieces/piece-blue.png")
export var west_sprite = preload("res://assets/pieces/king/image_part_066.png")
export var grid: Resource = preload("res://src/world/board/Grid.tres")

var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected
var _is_walking := false setget _set_is_walking
export var move_speed := 600.0

puppet var repl_cell = Vector2.ZERO

onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path: Path2D = $Path2D
onready var _path_follow: PathFollow2D = $Path2D/PathFollow2D
onready var sprite: Sprite = $Path2D/PathFollow2D/Sprite

onready var board = get_parent().get_parent()

export var piece_type = "officer" setget set_type
export var team = "blue"

var piece_name = "officer_blue"
var movable_cells := []

signal move_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	set_cell(grid.calculate_grid_coordinates(position))
	position = grid.calculate_map_position(cell)
	if not Engine.editor_hint:
		_path.curve = Curve2D.new()

func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

func get_cell() -> Vector2:
	return cell

func set_type(value: String) -> void:
	piece_type = value
	piece_name = piece_type + "_ " + team

func get_type() -> String:
	return piece_type

func get_team() -> String:
	return team

func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

func move_along_path(path: PoolVector2Array) -> void:
	if path.empty():
		return
	_path.curve.add_point(Vector2.ZERO)
	for point in path:
		_path.curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true

func set_sprite_style() -> void:
	if Gamestate.style == "W":
		set_sprite_western()
	elif Gamestate.style == "E":
		set_sprite_eastern()

func set_sprite_western() -> void:
	sprite.scale = Vector2(0.5, 0.5)
	sprite.texture = west_sprite

func set_sprite_eastern() -> void:
	sprite.scale = Vector2(0.3, 0.3)
	sprite.texture = east_sprite

func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)

func _process(delta):
	_path_follow.offset += move_speed * delta
	if _path_follow.unit_offset >= 1.0:
		self._is_walking = false
		_path_follow.offset = 0.0
		position = grid.calculate_map_position(cell)
		_path.curve.clear_points()
		emit_signal("move_finished")

func test_walk() -> void:
	var points := [
		Vector2(2, 2),
		Vector2(3, 3),
		Vector2(4, 4),
		Vector2(5, 5),
	]
	move_along_path(PoolVector2Array(points))
