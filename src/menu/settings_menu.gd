extends ColorRect

onready var piece_style = $piece_style
onready var board_style = $board_style
onready var back_button = $back
onready var piece_preview = $piece_preview
onready var board_preview = $board_preview
var east_sprite = preload("res://assets/pieces/knight/piece-shu-ma.png")
var west_sprite = preload("res://assets/pieces/knight/image_part_032.png")
var marble_board = preload("res://assets/board/marble-board.png")
var wood_board = preload("res://assets/board/wood-board.png")
var province_board = preload("res://assets/board/province-board.png")

signal back_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if back_button.connect("pressed", self, "_on_back_button_pressed") != OK:
		push_error("back button connect fail")
	if piece_style.connect("item_selected", self, "_on_piece_style_selected") != OK:
		push_error("item select button connect fail")
	if board_style.connect("item_selected", self, "_on_board_style_selected") != OK:
		push_error("item select button connect fail")
	piece_style.add_item("Staunton", 0)
	piece_style.add_item("Xiang", 1)
	board_style.add_item("Marble", 0)
	board_style.add_item("Wood", 1)
	board_style.add_item("Province", 2)

func _on_piece_style_selected(index) -> void:
	if index == 0:
		Gamestate.style = "W"
		piece_preview.texture = west_sprite
	elif index == 1:
		Gamestate.style = "E"
		piece_preview.texture = east_sprite

func _on_board_style_selected(index) -> void:
	if index == 0:
		Gamestate.board_style = "marble"
		board_preview.texture = marble_board
	elif index == 1:
		Gamestate.board_style = "wood"
		board_preview.texture = wood_board
	elif index == 2:
		Gamestate.board_style = "province"
		board_preview.texture = province_board

func _on_back_button_pressed() -> void:
	emit_signal("back_pressed")
