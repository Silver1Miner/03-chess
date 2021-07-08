extends Control

onready var singleplayer_button = $VBoxContainer/singleplayer
onready var multiplayer_button = $VBoxContainer/multiplayer
onready var quit_button = $VBoxContainer/quit

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "HTML5":
		quit_button.visible = false
	if singleplayer_button.connect("pressed", self, "_on_singleplayer") != OK:
		push_error("button connect fail")
	if multiplayer_button.connect("pressed", self, "_on_multiplayer") != OK:
		push_error("button connect fail")
	if quit_button.connect("pressed", self, "_on_quit_button_pressed") != OK:
		push_error("quit button connect fail")

func _on_singleplayer() -> void:
	Gamestate.is_singleplayer = true
	if get_tree().change_scene("res://src/world/world.tscn") != OK:
		push_error("change scene fail")

func _on_multiplayer() -> void:
	Gamestate.is_singleplayer = false
	if get_tree().change_scene("res://src/lobby/lobby.tscn") != OK:
		push_error("change scene fail")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
