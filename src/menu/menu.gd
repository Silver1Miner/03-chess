extends Control

onready var options = $options
onready var singleplayer_button = $options/singleplayer
onready var multiplayer_button = $options/multiplayer
onready var settings_button = $options/settings
onready var quit_button = $options/quit
onready var settings_menu = $settings_menu
onready var singleplayer_menu = $singleplayer_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "HTML5":
		quit_button.visible = false
	if singleplayer_button.connect("pressed", self, "_on_singleplayer") != OK:
		push_error("button connect fail")
	if multiplayer_button.connect("pressed", self, "_on_multiplayer") != OK:
		push_error("button connect fail")
	if settings_button.connect("pressed", self, "_on_settings_button_pressed") != OK:
		push_error("button connect fail")
	if quit_button.connect("pressed", self, "_on_quit_button_pressed") != OK:
		push_error("quit button connect fail")
	if settings_menu.connect("back_pressed", self, "_on_settings_menu_close") != OK:
		push_error("settings back connect fail")
	if singleplayer_menu.connect("back_pressed", self, "_on_singleplayer_menu_close") != OK:
		push_error("singleplayer back connect fail")

func _on_singleplayer() -> void:
	Gamestate.is_singleplayer = true
	settings_menu.visible = false
	options.visible = false
	singleplayer_menu.visible = true
	singleplayer_menu.set_style()

func _on_multiplayer() -> void:
	Gamestate.is_singleplayer = false
	if get_tree().change_scene("res://src/lobby/lobby.tscn") != OK:
		push_error("change scene fail")

func _on_settings_button_pressed() -> void:
	settings_menu.visible = true
	singleplayer_menu.visible = false
	options.visible = false

func _on_settings_menu_close() -> void:
	settings_menu.visible = false
	singleplayer_menu.visible = false
	options.visible = true

func _on_singleplayer_menu_close() -> void:
	settings_menu.visible = false
	singleplayer_menu.visible = false
	options.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()
