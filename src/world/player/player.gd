extends Node2D #player.gd the player cursor

signal accept_pressed(cell, team)
signal cancel_pressed(cell, team)
signal moved(new_cell, team)

export var grid: Resource = preload("res://src/world/board/Grid.tres")
export var ui_cooldown := 0.1

export var team = "blue" setget set_team
var cell := Vector2.ZERO setget set_cell

onready var _sprite: Sprite = $Sprite
onready var _timer: Timer = $Timer
var board_position := Vector2(0, 0)
var colors := {"blue": Color(0.5,0.5,1), "red": Color(1,0.5,0.5), "green": Color(0.5,1,0.5)}

# Called when the node enters the scene tree for the first time.
func _ready():
	_timer.wait_time = ui_cooldown
	set_cell(grid.calculate_grid_coordinates(position))
	position = grid.calculate_map_position(cell)
	if not get_parent() is Viewport:
		board_position = get_parent().position
	set_team(team)

func set_cell(input: Vector2) -> void:
	var new_cell: Vector2 = grid.clamp(input)
	if new_cell.is_equal_approx(cell):
		return
	cell = new_cell
	position = grid.calculate_map_position(cell)
	emit_signal("moved", cell, team)

func set_team(input: String) -> void:
	team = input
	_sprite.modulate = colors[team]

func _unhandled_input(event) -> void:
	if Gamestate.is_singleplayer or Gamestate.player_info[team]:
		if event is InputEventMouseMotion:
			if grid.is_within_bounds(grid.calculate_grid_coordinates(event.position-board_position)):
				warp_cursor(event.position - board_position)
				#self.cell = grid.calculate_grid_coordinates(event.position - board_position)
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("left_click"):
			emit_signal("accept_pressed", cell, team)
			get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("right_click"):
			emit_signal("cancel_pressed", cell, team)
			get_tree().set_input_as_handled()
		var should_move = event.is_pressed()
		if event.is_echo():
			should_move = should_move and _timer.is_stopped()
		if not should_move:
			return
		if event.is_action("ui_right"):
			#self.cell += Vector2.RIGHT
			move_cursor(Vector2.RIGHT)
		elif event.is_action("ui_left"):
			#self.cell += Vector2.LEFT
			move_cursor(Vector2.LEFT)
		if event.is_action("ui_up"):
			#self.cell += Vector2.UP
			move_cursor(Vector2.UP)
		elif event.is_action("ui_down"):
			#self.cell += Vector2.DOWN
			move_cursor(Vector2.DOWN)

remote func warp_cursor(pos) -> void:
	if !Gamestate.is_singleplayer:
		if get_tree().is_network_server():
			for id in Network.players:
				if (id != 1):
					rpc_id(id, "warp_cursor_local", pos)
			warp_cursor_local(pos)
		else:
			rpc_id(1, "warp_cursor", pos)
	else:
		warp_cursor_local(pos)

remote func warp_cursor_local(pos) -> void:
	self.cell = grid.calculate_grid_coordinates(pos)

remote func move_cursor(direction: Vector2) -> void:
	if !Gamestate.is_singleplayer:
		if get_tree().is_network_server():
			for id in Network.players:
				if (id != 1):
					rpc_id(id, "move_cursor_local", direction)
			move_cursor_local(direction)
		else:
			rpc_id(1, "move_cursor", direction)
	else:
		move_cursor_local(direction)

remote func move_cursor_local(direction: Vector2) -> void:
	self.cell += direction

#func _draw() -> void:
#	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), colors[team], false, 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
