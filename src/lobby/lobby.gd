extends Control

onready var create_server_button = $CanvasLayer/VBoxContainer/Host/server_info/create_server_button
onready var join_server_button = $CanvasLayer/VBoxContainer/Join/join_server/join_server_button
onready var join_ip = $CanvasLayer/VBoxContainer/Join/join_server/join_options/ip_address
onready var join_port = $CanvasLayer/VBoxContainer/Join/join_server/join_options/port
onready var server_name = $CanvasLayer/VBoxContainer/Host/server_info/server_name
onready var server_port = $CanvasLayer/VBoxContainer/Host/server_info/server_options/server_port
onready var max_players = $CanvasLayer/VBoxContainer/Host/server_info/server_options/max_players

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Network.connect("server_created", self, "_on_ready_to_play") != OK:
		push_error("server signal connect fail")
	if Network.connect("join_success", self, "_on_ready_to_play") != OK:
		push_error("join signal connect fail")
	if Network.connect("join_fail", self, "_on_join_fail") != OK:
		push_error("join signal connect fail")
	if create_server_button.connect("pressed", self, "_on_create_server_button_pressed") != OK:
		push_error("create server button fail")
	if join_server_button.connect("pressed", self, "_on_join_server_button_pressed") != OK:
		push_error("join server button fail")

func _on_ready_to_play() -> void:
	if get_tree().change_scene("res://src/world/world.tscn") != OK:
		push_error("world change fail")

func _on_join_fail() -> void:
	print("Failed to join server")

func _on_create_server_button_pressed() -> void:
	if (!server_name.text.empty()):
		Network.server_info.name = server_name.text
	Network.server_info.max_players = int(max_players.value)
	Network.server_info.used_port = int(server_port.text)
	Network.create_server()

func _on_join_server_button_pressed() -> void:
	var port = int(join_port.text)
	var ip = join_ip.text
	Network.join_server(ip, port)
