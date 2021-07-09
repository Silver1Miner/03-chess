extends Node2D

onready var units := $units
onready var move_display := $move_display

var board_state := []
var board_display := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_board_state()
	populate_state_from_board()

func initialize_board_state() -> void:
	for x in range(9):
		board_state.append([])
		board_display.append([])
		for _y in range(9):
			board_state[x].append("")
			board_display[x].append("")

func populate_state_from_board() -> void:
	for unit in units.get_children():
		var x = unit.cell.x
		var y = unit.cell.y
		board_state[x][y] = unit
		board_display[x][y] = unit.piece_name

func populate_board_from_state() -> void:
	pass

func calculate_piece_movement() -> void:
	pass

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"): # DEBUGGING
		print(board_display)
		get_tree().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
