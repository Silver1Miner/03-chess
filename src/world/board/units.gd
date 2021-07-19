extends Node2D

onready var board = get_parent()
export var grid: Resource = preload("res://src/world/board/Grid.tres")

func calculate_king_move(cell: Vector2) -> Array:
	var moves = []
	var possible = [Vector2(-1,-1), Vector2(-1,0),
	Vector2(-1,1), Vector2(0,-1), Vector2(0,1),
	Vector2(1,-1), Vector2(1,0), Vector2(1,1)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell) and board.would_not_end_in_check(cell, new_cell):
			if board.board_state[cell.x][cell.y].team == "blue":
				if new_cell in board.currently_attacked_by_red or new_cell in board.currently_attacked_by_green:
					continue
			if board.board_state[cell.x][cell.y].team == "red":
				if new_cell in board.currently_attacked_by_blue or new_cell in board.currently_attacked_by_green:
					continue
			if board.board_state[cell.x][cell.y].team == "green":
				if new_cell in board.currently_attacked_by_red or new_cell in board.currently_attacked_by_blue:
					continue
			if board.board_state[new_cell.x][new_cell.y] == null:
				moves.append(new_cell)
			elif board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	return moves

func calculate_bishop_move(cell: Vector2) -> Array:
	var moves = []
	var possible = [Vector2(-1,-1), Vector2(1,1),
	Vector2(-1,1), Vector2(1,-1)]
	for p in possible:
		for i in range(1,9):
			var new_cell = cell + p * i
			if grid.is_within_bounds(new_cell):
				if board.board_state[new_cell.x][new_cell.y] == null and board.would_not_end_in_check(cell, new_cell):
					moves.append(new_cell)
				elif board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team and board.would_not_end_in_check(cell, new_cell):
					moves.append(new_cell)
					break
				else:
					break
	return moves

func calculate_knight_move(cell: Vector2) -> Array:
	var moves = []
	var possible = [Vector2(-2,-1), Vector2(-2,1),
	Vector2(-1,2), Vector2(1,2), Vector2(2,1),
	Vector2(2,-1), Vector2(-1,-2), Vector2(1,-2)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell) and board.would_not_end_in_check(cell, new_cell):
			if board.board_state[new_cell.x][new_cell.y] == null:
				moves.append(new_cell)
			elif board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	return moves

func calculate_pawn_move(cell: Vector2) -> Array:
	var moves = []
	var possible_cap = [Vector2(-1, 1), Vector2(1, 1)]
	var possible_mov = Vector2(0, 1)
	if board.board_state[cell.x][cell.y].team != "blue":
		possible_cap = [Vector2(-1, -1), Vector2(1, -1)]
		possible_mov = Vector2(0, -1)
	var new_cell = cell + possible_mov
	if grid.is_within_bounds(new_cell) and board.would_not_end_in_check(cell, new_cell):
		if board.board_state[new_cell.x][new_cell.y] == null:
			moves.append(new_cell)
	for p in possible_cap:
		new_cell = cell + p
		if grid.is_within_bounds(new_cell) and board.would_not_end_in_check(cell, new_cell):
			if board.board_state[new_cell.x][new_cell.y] != null and board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	return moves

func calculate_queen_move(cell: Vector2) -> Array:
	var moves = []
	var possible = [Vector2(-1,-1), Vector2(-1,0),
	Vector2(-1,1), Vector2(0,-1), Vector2(0,1),
	Vector2(1,-1), Vector2(1,0), Vector2(1,1)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell) and board.would_not_end_in_check(cell, new_cell):
			if board.board_state[new_cell.x][new_cell.y] == null:
				moves.append(new_cell)
			elif board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team:
				moves.append(new_cell)
	return moves

func calculate_rook_move(cell: Vector2) -> Array:
	var moves = []
	var possible = [Vector2(0,-1), Vector2(0,1),
	Vector2(-1,0), Vector2(1,0)]
	for p in possible:
		for i in range(1,9):
			var new_cell = cell + p * i
			if grid.is_within_bounds(new_cell):
				if board.board_state[new_cell.x][new_cell.y] == null and board.would_not_end_in_check(cell, new_cell):
					moves.append(new_cell)
				elif board.board_state[new_cell.x][new_cell.y] != null and board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team and board.would_not_end_in_check(cell, new_cell):
					moves.append(new_cell)
					break
				else:
					break
	return moves

func calculate_king_attacks(cell: Vector2) -> Array:
	var attacks = []
	var possible = [Vector2(-1,-1), Vector2(-1,0),
	Vector2(-1,1), Vector2(0,-1), Vector2(0,1),
	Vector2(1,-1), Vector2(1,0), Vector2(1,1)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell):
			attacks.append(new_cell)
	return attacks

func calculate_bishop_attacks(cell: Vector2) -> Array:
	var attacks = []
	var possible = [Vector2(-1,-1), Vector2(1,1),
	Vector2(-1,1), Vector2(1,-1)]
	for p in possible:
		for i in range(1,9):
			var new_cell = cell + p * i
			if grid.is_within_bounds(new_cell):
				if board.board_state[new_cell.x][new_cell.y] == null:
					attacks.append(new_cell)
				elif board.board_state[new_cell.x][new_cell.y].piece_type == "king" and board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team:
					attacks.append(new_cell)
				else:
					attacks.append(new_cell)
					break
	return attacks

func calculate_knight_attacks(cell: Vector2) -> Array:
	var attacks = []
	var possible = [Vector2(-2,-1), Vector2(-2,1),
	Vector2(-1,2), Vector2(1,2), Vector2(2,1),
	Vector2(2,-1), Vector2(-1,-2), Vector2(1,-2)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell):
			attacks.append(new_cell)
	return attacks

func calculate_pawn_attacks(cell: Vector2) -> Array:
	var attacks = []
	var possible_cap = [Vector2(-1, 1), Vector2(1, 1)]
	if board.board_state[cell.x][cell.y] != null and board.board_state[cell.x][cell.y].team != "blue":
		possible_cap = [Vector2(-1, -1), Vector2(1, -1)]
	for p in possible_cap:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell):
			attacks.append(new_cell)
	return attacks

func calculate_queen_attacks(cell: Vector2) -> Array:
	var attacks = []
	var possible = [Vector2(-1,-1), Vector2(-1,0),
	Vector2(-1,1), Vector2(0,-1), Vector2(0,1),
	Vector2(1,-1), Vector2(1,0), Vector2(1,1)]
	for p in possible:
		var new_cell = cell + p
		if grid.is_within_bounds(new_cell):
			attacks.append(new_cell)
	return attacks

func calculate_rook_attacks(cell: Vector2) -> Array:
	var attacks = []
	var possible = [Vector2(0,-1), Vector2(0,1),
	Vector2(-1,0), Vector2(1,0)]
	for p in possible:
		for i in range(1,9):
			var new_cell = cell + p * i
			if grid.is_within_bounds(new_cell):
				if board.board_state[new_cell.x][new_cell.y] == null:
					attacks.append(new_cell)
				elif board.board_state[new_cell.x][new_cell.y].piece_type == "king" and board.board_state[new_cell.x][new_cell.y].team != board.board_state[cell.x][cell.y].team:
					attacks.append(new_cell)
				else:
					attacks.append(new_cell)
					break
	return attacks
