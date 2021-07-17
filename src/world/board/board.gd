extends Node2D

export var grid: Resource = preload("res://src/world/board/Grid.tres")

onready var units := $units
onready var move_display := $move_display
onready var player = $player

var board_state := []
var board_display := []
var prev_board_state := []
var prev_board_display := []

var selected_piece = null
var moves := []
var currently_attacked_by_blue := []
var currently_attacked_by_red := []
var currently_attacked_by_green := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		player.connect("accept_pressed", self, "_on_accept_pressed")
		player.connect("cancel_pressed", self, "_on_cancel_pressed")
		player.connect("moved", self, "_on_player_moved")
	initialize_board_state()
	populate_state_from_board()
	calculate_current_attacked_squares()

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
	print(team, " pressed select at ", cell)
	if selected_piece != null:
		if cell in moves:
			print("move ", selected_piece.piece_name, " to ", cell)
			move_display.clear()
			move_from_to(selected_piece.cell, cell)
		elif board_display[cell.x][cell.y] == "":
			selected_piece = null
			move_display.clear()
		elif team == board_state[cell.x][cell.y].team:
			selected_piece = board_state[cell.x][cell.y]
			calculate_piece_movement(cell)
		return
	if board_display[cell.x][cell.y] != "":
		print(board_state[cell.x][cell.y])
		if team == board_state[cell.x][cell.y].team:
			selected_piece = board_state[cell.x][cell.y]
			calculate_piece_movement(cell)
	else:
		selected_piece = null
		move_display.clear_moves()

func _on_cancel_pressed(cell, team) -> void:
	print(team, " pressed cancel at ", cell)
	var attacks = []
	var piece = board_state[cell.x][cell.y]
	if piece == null:
		move_display.clear_moves()
		return
	match piece.piece_type:
		"king":
			attacks = units.calculate_king_attacks(piece.cell)
		"bishop":
			attacks = units.calculate_bishop_attacks(piece.cell)
		"knight":
			attacks = units.calculate_knight_attacks(piece.cell)
		"pawn":
			attacks = units.calculate_pawn_attacks(piece.cell)
		"queen":
			attacks = units.calculate_queen_attacks(piece.cell)
		"rook":
			attacks = units.calculate_rook_attacks(piece.cell)
	move_display.draw_attacked(attacks)

func _on_player_moved(cell, team) -> void:
	print(team, " moved cursor to ", cell)

func move_from_to(start_cell, end_cell) -> void:
	board_state[start_cell.x][start_cell.y].move_along_path([start_cell, end_cell])
	board_display[start_cell.x][start_cell.y] = ""
	board_display[end_cell.x][end_cell.y] = board_state[start_cell.x][start_cell.y].piece_name
	if board_state[end_cell.x][end_cell.y] != null:
		print(board_state[end_cell.x][end_cell.y].piece_name, " captured at ", end_cell)
		board_state[end_cell.x][end_cell.y].queue_free()
	board_state[end_cell.x][end_cell.y] = board_state[start_cell.x][start_cell.y]
	board_state[start_cell.x][start_cell.y] = null
	if board_state[end_cell.x][end_cell.y].piece_type == "pawn":
		if board_state[end_cell.x][end_cell.y].team == "blue" and end_cell.y > 5:
			board_state[end_cell.x][end_cell.y].change_to_queen()
		elif board_state[end_cell.x][end_cell.y].team == "red" and end_cell.y < 3:
			board_state[end_cell.x][end_cell.y].change_to_queen()
		elif board_state[end_cell.x][end_cell.y].team == "green" and end_cell.y < 3:
			board_state[end_cell.x][end_cell.y].change_to_queen()
	calculate_current_attacked_squares()
	check()
	next_turn()

func calculate_piece_movement(cell: Vector2) -> void:
	moves.clear()
	print(board_state[cell.x][cell.y].piece_name)
	match board_state[cell.x][cell.y].piece_type:
		"king":
			moves = units.calculate_king_move(cell, board_state[cell.x][cell.y].team)
		"bishop":
			moves = units.calculate_bishop_move(cell)
		"knight":
			moves = units.calculate_knight_move(cell)
		"pawn":
			moves = units.calculate_pawn_move(cell)
		"queen":
			moves = units.calculate_queen_move(cell)
		"rook":
			moves = units.calculate_rook_move(cell)
	move_display.draw_moves(moves)
	print(board_state[cell.x][cell.y].piece_type, " moves: ", moves)

func calculate_current_attacked_squares() -> void:
	currently_attacked_by_blue.clear()
	currently_attacked_by_red.clear()
	currently_attacked_by_green.clear()
	for piece in units.get_children():
		var attacks = []
		match piece.piece_type:
			"king":
				attacks = units.calculate_king_attacks(piece.cell)
			"bishop":
				attacks = units.calculate_bishop_attacks(piece.cell)
			"knight":
				attacks = units.calculate_knight_attacks(piece.cell)
			"pawn":
				attacks = units.calculate_pawn_attacks(piece.cell)
			"queen":
				attacks = units.calculate_queen_attacks(piece.cell)
			"rook":
				attacks = units.calculate_rook_attacks(piece.cell)
		match piece.team:
			"blue":
				for move in attacks:
					if not move in currently_attacked_by_blue:
						currently_attacked_by_blue.append(move)
			"red":
				for move in attacks:
					if not move in currently_attacked_by_red:
						currently_attacked_by_red.append(move)
			"green":
				for move in attacks:
					if not move in currently_attacked_by_green:
						currently_attacked_by_green.append(move)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_home"): # DEBUGGING
		print(board_display)
	if event.is_action_pressed("ui_focus_next"):
		next_turn()

func next_turn() -> void:
	if player.team == "blue":
		player.set_team("red")
		print("Red's turn")
	elif player.team == "red":
		player.set_team("green")
		print("Green's turn")
	else:
		player.set_team("blue")
		print("Blue's turn")

func check() -> void:
	var blue_checks = []
	for sq in currently_attacked_by_blue:
		if board_display[sq.x][sq.y] == "king_red":
			print("Red in check")
			blue_checks.append(sq)
		if board_display[sq.x][sq.y] == "king_green":
			print("Green in check")
			blue_checks.append(sq)
	move_display.add_draw_attacked(blue_checks)
	var red_checks = []
	for sq in currently_attacked_by_red:
		if board_display[sq.x][sq.y] == "king_blue":
			print("Blue in check")
			red_checks.append(sq)
		if board_display[sq.x][sq.y] == "king_green":
			print("Green in check")
			red_checks.append(sq)
	move_display.add_draw_attacked(red_checks)
	var green_checks = []
	for sq in currently_attacked_by_green:
		if board_display[sq.x][sq.y] == "king_red":
			print("Red in check")
			green_checks.append(sq)
		if board_display[sq.x][sq.y] == "king_blue":
			print("Blue in check")
			green_checks.append(sq)
	move_display.add_draw_attacked(green_checks)
