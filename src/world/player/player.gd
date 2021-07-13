extends Node2D

signal accept_pressed(cell, team)
signal moved(new_cell, team)

export var is_singleplayer := true
export var grid: Resource = preload("res://src/world/board/Grid.tres")
export var ui_cooldown := 0.1

export var team = "blue" setget set_team
var cell := Vector2.ZERO setget set_cell
puppet var repl_cell = Vector2.ZERO

onready var _timer: Timer = $Timer
onready var board = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_timer.wait_time = ui_cooldown
	set_cell(grid.calculate_grid_coordinates(position))

func set_cell(input: Vector2) -> void:
	var new_cell: Vector2 = grid.clamp(input)
	if new_cell.is_equal_approx(cell):
		return
	cell = new_cell
	position = grid.calculate_map_position(cell)
	emit_signal("moved", cell, team)

func set_team(input: String) -> void:
	team = input

func _unhandled_input(event) -> void:
	if is_singleplayer or is_network_master():
		if event is InputEventMouseMotion and not board is Viewport:
			if (event.position - board.position).x > 0 and (event.position - board.position).x < (64 * 9) and (event.position - board.position).y > 0 and (event.position - board.position).y < (64 * 9):
				self.cell = grid.calculate_grid_coordinates(event.position - board.position)
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("left_click"):
			emit_signal("accept_pressed", cell, team)
			get_tree().set_input_as_handled()
		var should_move = event.is_pressed()
		if event.is_echo():
			should_move = should_move and _timer.is_stopped()
		if not should_move:
			return
		if event.is_action("ui_right"):
			self.cell += Vector2.RIGHT
		elif event.is_action("ui_left"):
			self.cell += Vector2.LEFT
		if event.is_action("ui_up"):
			self.cell += Vector2.UP
		elif event.is_action("ui_down"):
			self.cell += Vector2.DOWN
		if !is_singleplayer:
			rset("repl_cell", self.cell)
	else:
		set_cell(repl_cell)

func _draw() -> void:
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.aliceblue, false, 2.0)

func set_dominant_color(color):
	$Sprite.modulate = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
