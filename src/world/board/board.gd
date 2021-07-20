extends Node2D

export var grid: Resource = preload("res://src/world/board/Grid.tres")

onready var units := $units
onready var move_display := $move_display
onready var player = $player

var board_state := []
var board_display := []

var selected_piece = null
var moves := []
var currently_attacked_by_blue := []
var currently_attacked_by_red := []
var currently_attacked_by_green := []

var endgame_state := "playing"
var move_log := []
var current_turn := "blue"
var blue_in_check := false
var red_in_check := false
var green_in_check := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		player.connect("accept_pressed", self, "_on_accept_pressed")
		player.connect("cancel_pressed", self, "_on_cancel_pressed")
		player.connect("moved", self, "_on_player_moved")
	initialize_board_state()
	populate_state_from_board()
	calculate_current_attacked_squares()
	check()
	endgame_state = checkmate_stalemate_checker()
	print(endgame_state)

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
		elif board_state[cell.x][cell.y] == null:
			selected_piece = null
			move_display.clear()
		elif team == board_state[cell.x][cell.y].team:
			selected_piece = board_state[cell.x][cell.y]
			calculate_piece_movement(cell)
		return
	if board_state[cell.x][cell.y] != null:
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

func _on_player_moved(_cell, _team) -> void:
	#print(team, " moved cursor to ", cell)
	pass

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
	selected_piece = null
	calculate_current_attacked_squares()
	check()
	next_turn()

func calculate_piece_movement(cell: Vector2) -> void:
	moves.clear()
	print(board_state[cell.x][cell.y].piece_name)
	match board_state[cell.x][cell.y].piece_type:
		"king":
			moves = units.calculate_king_move(cell)
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
		current_turn = "red"
		print("Red's turn")
	elif player.team == "red":
		player.set_team("green")
		current_turn = "green"
		print("Green's turn")
	else:
		player.set_team("blue")
		current_turn = "blue"
		print("Blue's turn")
	check()
	endgame_state = checkmate_stalemate_checker()

func check() -> void:
	move_display.clear_attacked()
	var blue_checks = []
	for sq in currently_attacked_by_blue:
		if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_red":
			print("Red in check")
			red_in_check = true
			blue_checks.append(sq)
		if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_green":
			print("Green in check")
			green_in_check = true
			blue_checks.append(sq)
	move_display.add_draw_attacked(blue_checks)
	var red_checks = []
	for sq in currently_attacked_by_red:
		if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_blue":
			print("Blue in check")
			blue_in_check = true
			red_checks.append(sq)
		if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_green":
			print("Green in check")
			green_in_check = true
			red_checks.append(sq)
	move_display.add_draw_attacked(red_checks)
	var green_checks = []
	for sq in currently_attacked_by_green:
		if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_red":
			print("Red in check")
			red_in_check = true
			green_checks.append(sq)
		if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_blue":
			print("Blue in check")
			blue_in_check = true
			green_checks.append(sq)
	move_display.add_draw_attacked(green_checks)

func would_not_end_in_check(cell, new_cell) -> bool:
	var team = board_state[cell.x][cell.y].team
	var in_check = true
	var prev_state = board_state.duplicate(true)
	board_state[cell.x][cell.y].cell = new_cell
	if board_state[new_cell.x][new_cell.y] != null:
		board_state[new_cell.x][new_cell.y].cell = Vector2(100,100)
	board_state[new_cell.x][new_cell.y] = board_state[cell.x][cell.y]
	board_state[cell.x][cell.y] = null
	calculate_current_attacked_squares()
	match team:
		"blue":
			for sq in currently_attacked_by_red:
				if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_blue":
					in_check = false
			for sq in currently_attacked_by_green:
				if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_blue":
					in_check = false
		"red":
			for sq in currently_attacked_by_blue:
				if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_red":
					in_check = false
			for sq in currently_attacked_by_green:
				if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_red":
					in_check = false
		"green":
			for sq in currently_attacked_by_blue:
				if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_green":
					in_check = false
			for sq in currently_attacked_by_red:
				if board_state[sq.x][sq.y] != null and board_state[sq.x][sq.y].piece_name == "king_green":
					in_check = false
	board_state = prev_state.duplicate(true)
	board_state[cell.x][cell.y].cell = cell
	if board_state[new_cell.x][new_cell.y] != null:
		board_state[new_cell.x][new_cell.y].cell = new_cell
	return in_check

func checkmate_stalemate_checker() -> String:
	var all_blue_moves = get_all_legal_moves("blue")
	var all_red_moves = get_all_legal_moves("red")
	var all_green_moves = get_all_legal_moves("green")
	match current_turn:
		"blue":
			if not all_blue_moves:
				if blue_in_check:
					print("blue lost")
					return "blue checkmated"
				else:
					print("stalemate")
					return "stalemate"
		"red":
			if not all_red_moves:
				if red_in_check:
					print("red lost")
					return "red checkmated"
				else:
					print("stalemate")
					return "stalemate"
		"green":
			if not all_green_moves:
				if green_in_check:
					print("green lost")
					return "green checkmated"
				else:
					print("stalemate")
					return "stalemate"
	return "playing"

func get_all_legal_moves(team) -> Array:
	var legal_moves = []
	for piece in units.get_children():
		if piece.team == team:
			var piece_moves = []
			match piece.piece_type:
				"king":
					piece_moves = units.calculate_king_move(piece.cell)
				"bishop":
					piece_moves = units.calculate_bishop_move(piece.cell)
				"knight":
					piece_moves = units.calculate_knight_move(piece.cell)
				"pawn":
					piece_moves = units.calculate_pawn_move(piece.cell)
				"queen":
					piece_moves = units.calculate_queen_move(piece.cell)
				"rook":
					piece_moves = units.calculate_rook_move(piece.cell)
			legal_moves += piece_moves
	return legal_moves
