extends Node2D
class_name Unit

export var grid: Resource = preload("res://src/world/board/Grid.tres")
var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected

puppet var repl_cell = Vector2.ZERO

onready var _anim_player: AnimationPlayer = $AnimationPlayer

export var piece_type = "officer"
export var team = 1 # 1 blue 2 red 3 green
var movable_cells := []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_cell(grid.calculate_grid_coordinates(position))
	position = grid.calculate_map_position(cell)

func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		pass
		#_anim_player.play("selected")
	else:
		pass
		#_anim_player.play("idle")

func move_along_path(_path: PoolVector2Array) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
