extends Node # AI.gd the AI player

onready var board = get_parent()
export var grid: Resource = preload("res://src/world/board/Grid.tres")
var piece_list = null
var ai_color = "red"
var t = Timer.new()

func _ready() -> void:
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	add_child(t)
	if not board is Viewport:
		piece_list = board.get_node("units").get_children()

func action(color) -> void:
	ai_color = color
	random_move(color)

func random_move(color) -> void:
	var legal_moves = board.get_all_legal_moves(color)
	randomize()
	if legal_moves.size() > 0:
		var ri = randi() % legal_moves.size()
		print(ri)
		print(legal_moves)
		t.start()
		yield(t, "timeout")
		board.move_from_to(legal_moves[ri][0],legal_moves[ri][1])

func score_piece(piece, team) -> float:
	var multiplier = 1
	if(piece.team == team):
		multiplier = -1
	if team == "red" or team == "green":
		if piece.team == "red" or piece.team == "green":
			multiplier = -1
	var abs_score = 0
	match piece.type:
		"king":
			abs_score = 900
		"queen":
			abs_score = 40
		"rook":
			abs_score = 50
		"bishop":
			abs_score = 30
		"knight":
			abs_score = 30
		"pawn":
			abs_score = 10
	return(multiplier * abs_score)

func evaluate_board() -> float:
	var eval = 0
	for piece in piece_list:
		eval += score_piece(piece, ai_color)
	return(eval)

class MinimaxResult:
	var move
	var eval_move

func evaluate_moves(color) -> void:
	var _legal_moves = board.get_all_legal_moves(color)
