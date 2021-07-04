extends Node2D
class_name Unit

export var grid: Resource = preload("res://src/world/board/Grid.tres")
var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected

onready var _anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
