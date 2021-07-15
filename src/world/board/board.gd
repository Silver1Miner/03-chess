extends Node2D

export var grid: Resource = preload("res://src/world/board/Grid.tres")

onready var units := $units
onready var move_display := $move_display
onready var player = $player

var board_state := []
var board_display := []

var selected_piece = null
var moves := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		player.connect("accept_pressed", self, "_on_accept_pressed")
	initialize_board_state()
	populate_state_from_board()

func initialize_board_state() -> void:
	for x in range(9):
		board_state.append([])
		board_display.append([])
		for _y in range(9):
			board_state[x].append(null)
			board_display[x].append("")

func populate_state_from_board() -> void:
	for unit in units.get_children():
		var x = unit.cell.x
		var y = unit.cell.y
		board_state[x][y] = unit
		board_display[x][y] = unit.piece_name

func _on_accept_pressed(cell, team) -> void:
	if selected_piece != null:
		if cell in moves:
			print("move ", selected_piece.piece_name, " to ", cell)
			move_from_to(selected_piece.cell, cell)
		selected_piece = null
		move_display.clear()
		return
	if board_display[cell.x][cell.y] != "":
		print(board_state[cell.x][cell.y])
		if team == board_state[cell.x][cell.y].team:
			selected_piece = board_state[cell.x][cell.y]
			calculate_piece_movement(cell)
	else:
		selected_piece = null
		move_display.clear()

func move_from_to(start_cell, end_cell) -> void:
	board_state[start_cell.x][start_cell.y].move_along_path([start_cell, end_cell])
	board_display[start_cell.x][start_cell.y] = ""
	board_display[end_cell.x][end_cell.y] = board_state[start_cell.x][start_cell.y].piece_name
	if board_state[end_cell.x][end_cell.y] != null:
		print(board_state[end_cell.x][end_cell.y].piece_name, " captured at ", end_cell)
		board_state[end_cell.x][end_cell.y].queue_free()
	board_state[end_cell.x][end_cell.y] = board_state[start_cell.x][start_cell.y]
	board_state[start_cell.x][start_cell.y] = null

func calculate_piece_movement(cell: Vector2) -> void:
	print(board_state[cell.x][cell.y].piece_name)
	match board_state[cell.x][cell.y].piece_type:
		"king":
			calculate_king_move(cell)
		"bishop":
			calculate_bishop_move(cell)
		"knight":
			calculate_knight_move(cell)
		"pawn":
			calculate_pawn_move(cell)
		"queen":
			calculate_queen_move(cell)
		"rook":
			calculate_rook_move(cell)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"): # DEBUGGING
		print(board_display)
		get_tree().set_input_as_handled()
	if event.is_action_pressed("ui_focus_next"):
		if player.team == "blue":
			player.set_team("red")
			print("Red's turn")
		elif player.team == "red":
			player.set_team("green")
			print("Green's turn")
		else:
			player.set_team("blue")
			print("Blue's turn")

func calculate_king_move(cell: Vector2) -> void:
	moves = []
	var possible = [Vector2(-1,-1), Vector2(-1,0),
	Vector2(-1,1), Vector2(0,-1), Vector2(0,1),
	Vector2(1,-1), Vector2(1,0), Vector2(1,1)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell):
			if board_display[new_cell.x][new_cell.y] == "":
				moves.append(new_cell)
			elif board_state[new_cell.x][new_cell.y].team != board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	move_display.draw(moves)
	print("king moves: ", moves)

func calculate_bishop_move(cell: Vector2) -> void:
	moves = []
	var possible = [Vector2(-1,-1), Vector2(1,1),
	Vector2(-1,1), Vector2(1,-1)]
	for p in possible:
		for i in range(1,9):
			var new_cell = cell + p * i
			if grid.is_within_bounds(new_cell):
				if board_display[new_cell.x][new_cell.y] == "":
					moves.append(new_cell)
				elif board_state[new_cell.x][new_cell.y].team != board_state[cell.x][cell.y].team:
					moves.append(new_cell)
					break
				else:
					break
	move_display.draw(moves)
	print("bishop moves: ", moves)

func calculate_knight_move(cell: Vector2) -> void:
	moves = []
	var possible = [Vector2(-2,-1), Vector2(-2,1),
	Vector2(-1,2), Vector2(1,2), Vector2(2,1),
	Vector2(2,-1), Vector2(-1,-2), Vector2(1,-2)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell):
			if board_display[new_cell.x][new_cell.y] == "":
				moves.append(new_cell)
			elif board_state[new_cell.x][new_cell.y].team != board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	move_display.draw(moves)
	print("knight moves: ", moves)

func calculate_pawn_move(cell: Vector2) -> void:
	moves = []
	var possible_cap = [Vector2(-1, 1), Vector2(1, 1)]
	var possible_mov = Vector2(0, 1)
	if board_state[cell.x][cell.y].team != "blue":
		possible_cap = [Vector2(-1, -1), Vector2(1, -1)]
		possible_mov = Vector2(0, -1)
	var new_cell = cell + possible_mov
	if grid.is_within_bounds(new_cell) and board_display[new_cell.x][new_cell.y] == "":
		moves.append(new_cell)
	for p in possible_cap:
		new_cell = cell + p
		if grid.is_within_bounds(new_cell) and board_display[new_cell.x][new_cell.y] != "":
			if board_state[new_cell.x][new_cell.y].team != board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	move_display.draw(moves)
	print("pawn moves: ", moves)

func calculate_queen_move(cell: Vector2) -> void:
	moves = []
	var possible = [Vector2(-1,-1), Vector2(-1,0),
	Vector2(-1,1), Vector2(0,-1), Vector2(0,1),
	Vector2(1,-1), Vector2(1,0), Vector2(1,1)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell):
			if board_display[new_cell.x][new_cell.y] == "":
				moves.append(new_cell)
			elif board_state[new_cell.x][new_cell.y].team != board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	move_display.draw(moves)
	print("queen moves: ", moves)

func calculate_rook_move(cell: Vector2) -> void:
	moves = []
	var possible = [Vector2(0,-1), Vector2(0,1),
	Vector2(-1,0), Vector2(1,0)]
	for p in possible:
		for i in range(1,9):
			var new_cell = cell + p * i
			if grid.is_within_bounds(new_cell):
				if board_display[new_cell.x][new_cell.y] == "":
					moves.append(new_cell)
				elif board_state[new_cell.x][new_cell.y].team != board_state[cell.x][cell.y].team:
					moves.append(new_cell)
					break
				else:
					break
	move_display.draw(moves)
	print("rook moves: ", moves)
