extends Panel

onready var to_main = $to_main

func _ready() -> void:
	if to_main.connect("pressed", self, "_on_to_main_pressed") != OK:
		push_error("button connect fail")

func _on_to_main_pressed() -> void:
	if get_tree().change_scene("res://src/menu/menu.tscn") != OK:
		push_error("main menu change fail")
