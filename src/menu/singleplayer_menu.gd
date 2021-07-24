extends ColorRect

onready var start_button = $start
onready var close_button = $close
onready var red_p = $grid/red
onready var blue_p = $grid/blue
onready var green_p = $grid/green
onready var red_ai = $grid/red_ai
onready var blue_ai = $grid/blue_ai
onready var green_ai = $grid/green_ai
var blue_w = preload("res://assets/pieces/king/image_part_066.png")
var red_w = preload("res://assets/pieces/king/image_part_036.png")
var green_w = preload("res://assets/pieces/king/image_part_054.png")
var blue_e = preload("res://assets/pieces/king/piece-wei.png")
var red_e = preload("res://assets/pieces/king/piece-shu.png")
var green_e = preload("res://assets/pieces/king/piece-wu.png")

signal back_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_style()
	if start_button.connect("pressed", self, "_on_start_pressed") != OK:
		push_error("start button connect fail")
	if close_button.connect("pressed", self, "_on_close_pressed") != OK:
		push_error("close button connect fail")
	if blue_ai.connect("toggled", self, "_on_blue_ai_toggled") != OK:
		push_error("blue ai button connect fail")
	if red_ai.connect("toggled", self, "_on_red_ai_toggled") != OK:
		push_error("red ai button connect fail")
	if green_ai.connect("toggled", self, "_on_green_ai_toggled") != OK:
		push_error("green ai button connect fail")


func _on_close_pressed() -> void:
	emit_signal("back_pressed")

func _on_start_pressed() -> void:
	Gamestate.is_singleplayer = true
	if get_tree().change_scene("res://src/world/world.tscn") != OK:
		push_error("change scene fail")

func _on_blue_ai_toggled(toggled) -> void:
	Gamestate.blue_ai = toggled
	if toggled:
		blue_ai.text = "CPU"
	else:
		blue_ai.text = "Human"

func _on_red_ai_toggled(toggled) -> void:
	Gamestate.red_ai = toggled
	if toggled:
		red_ai.text = "CPU"
	else:
		red_ai.text = "Human"

func _on_green_ai_toggled(toggled) -> void:
	Gamestate.green_ai = toggled
	if toggled:
		green_ai.text = "CPU"
	else:
		green_ai.text = "Human"

func set_style() -> void:
	if Gamestate.style == "W":
		blue_p.texture = blue_w
		green_p.texture = green_w
		red_p.texture = red_w
	elif Gamestate.style == "E":
		blue_p.texture = blue_e
		green_p.texture = green_e
		red_p.texture = red_e
