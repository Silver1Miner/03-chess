extends Control # lobby.gd The multiplayer lobby

onready var back_button = $CanvasLayer/back_main
onready var player_name_edit = $CanvasLayer/lobby_options/Player/name/name_edit
onready var create_server_button = $CanvasLayer/lobby_options/Host/server_info/create_server_button
onready var join_server_button = $CanvasLayer/lobby_options/Join/join_server/join_server_button
onready var join_ip = $CanvasLayer/lobby_options/Join/join_server/join_options/ip_address
onready var join_port = $CanvasLayer/lobby_options/Join/join_server/join_options/port
onready var server_name = $CanvasLayer/lobby_options/Host/server_info/server_name
onready var server_port = $CanvasLayer/lobby_options/Host/server_info/server_options/server_port
onready var max_players = $CanvasLayer/lobby_options/Host/server_info/server_options/max_players
onready var get_ip_button = $CanvasLayer/lobby_options/Host/server_info/get_ip

onready var hud_player_list = $CanvasLayer/lobby_info/player_list

onready var blue_player_assign = $CanvasLayer/lobby_info/blue_player
onready var red_player_assign = $CanvasLayer/lobby_info/red_player
onready var green_player_assign = $CanvasLayer/lobby_info/green_player
var blue_assigned = false
var red_assigned = false
var green_assigned = false

onready var start_game_button = $CanvasLayer/lobby_info/start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "HTML5":
		create_server_button.disabled = true
		get_ip_button.disabled = true
	if Network.connect("server_created", self, "_on_ready_to_play") != OK:
		push_error("server signal connect fail")
	if Network.connect("join_success", self, "_on_ready_to_play") != OK:
		push_error("join signal connect fail")
	if Network.connect("join_fail", self, "_on_join_fail") != OK:
		push_error("join signal connect fail")
	if Network.connect("player_list_changed", self, "_on_player_list_changed") != OK:
		push_error("player list change signal connect fail")
	if get_ip_button.connect("pressed", self, "_on_get_ip_pressed") != OK:
		push_error("get ip button connect fail")
	if create_server_button.connect("pressed", self, "_on_create_server_button_pressed") != OK:
		push_error("create server button connect fail")
	if join_server_button.connect("pressed", self, "_on_join_server_button_pressed") != OK:
		push_error("join server button connect fail")
	if back_button.connect("pressed", self, "_on_back_button_pressed") != OK:
		push_error("back button connect fail")
	if start_game_button.connect("pressed", self, "start_game") != OK:
		push_error("start game button connect fail")
	if blue_player_assign.connect("item_selected", self, "_on_blue_select") != OK:
		push_error("select connect fail")
	if red_player_assign.connect("item_selected", self, "_on_red_select") != OK:
		push_error("select connect fail")
	if green_player_assign.connect("item_selected", self, "_on_green_select") != OK:
		push_error("select connect fail")
	if OS.has_environment("Username"):
		player_name_edit.text = OS.get_environment("Username")
	else:
		player_name_edit.text = "Default Name"

func _on_back_button_pressed() -> void:
	if get_tree().change_scene("res://src/menu/menu.tscn") != OK:
		push_error("main menu change fail")

func set_player_info() -> void:
	if (!player_name_edit.text.empty()):
		Gamestate.player_info.player_name = player_name_edit.text

remotesync func _on_ready_to_play() -> void:
	check_ready()

remote func start_game() -> void:
	if get_tree().is_network_server():
		for id in Network.players:
			if (id != 1):
				rpc_id(id, "start_game")
	if get_tree().change_scene("res://src/world/world.tscn") != OK:
		push_error("world change fail")

func _on_join_fail() -> void:
	print("Failed to join server")

func _on_create_server_button_pressed() -> void:
	Gamestate.is_singleplayer = false
	set_player_info()
	if (!server_name.text.empty()):
		Network.server_info.name = server_name.text
	Network.server_info.max_players = int(max_players.value)
	Network.server_info.used_port = int(server_port.text)
	Network.create_server()

func _on_join_server_button_pressed() -> void:
	Gamestate.is_singleplayer = false
	set_player_info()
	var port = int(join_port.text)
	var ip = join_ip.text
	Network.join_server(ip, port)

func _on_player_list_changed() -> void:
	# remove all children from hud list
	for c in hud_player_list.get_children():
		c.queue_free()
	red_player_assign.clear()
	blue_player_assign.clear()
	green_player_assign.clear()
	red_player_assign.add_item("Red Player", 0)
	blue_player_assign.add_item("Blue Player", 0)
	green_player_assign.add_item("Green Player", 0)
	# iterate through player list creating new entries
	var values = Network.players.keys()
	values.sort()
	for p in values:
		var nlabel = Label.new()
		nlabel.text = Network.players[p].player_name + " " + str(Network.players[p].join_order)
		hud_player_list.add_child(nlabel)
		red_player_assign.add_item(Network.players[p].player_name + " " + str(Network.players[p].join_order), Network.players[p].join_order)
		blue_player_assign.add_item(Network.players[p].player_name + " " + str(Network.players[p].join_order), Network.players[p].join_order)
		green_player_assign.add_item(Network.players[p].player_name + " " + str(Network.players[p].join_order), Network.players[p].join_order)

func _on_get_ip_pressed() -> void:
	if OS.shell_open("https://icanhazip.com/") != OK:
		push_error("shell open fail")

remote func check_ready() -> void:
	if get_tree().is_network_server():
		for id in Network.players:
			if (id != 1):
				rpc_id(id, "check_ready")
	print(Network.players)
	if red_assigned and blue_assigned and green_assigned:
		start_game_button.disabled = false
	else:
		start_game_button.disabled = true

remote func _on_blue_select(index) -> void:
	print(index)
	blue_player_assign.select(index)
	if get_tree().is_network_server():
		for id in Network.players:
			if (id != 1):
				rpc_id(id, "_on_blue_select", index)
	for p in Network.players:
		if Network.players[p].join_order == index:
			Network.players[p]["blue"] = true
		else:
			Network.players[p]["blue"] = false
	blue_assigned = true
	if index == 0:
		blue_assigned = false
	check_ready()

remote func _on_red_select(index) -> void:
	print(index)
	red_player_assign.select(index)
	if get_tree().is_network_server():
		for id in Network.players:
			if (id != 1):
				rpc_id(id, "_on_red_select", index)
	for p in Network.players:
		if Network.players[p].join_order == index:
			Network.players[p]["red"] = true
		else:
			Network.players[p]["red"] = false
	red_assigned = true
	if index == 0:
		red_assigned = false
	check_ready()

remote func _on_green_select(index) -> void:
	print(index)
	green_player_assign.select(index)
	if get_tree().is_network_server():
		for id in Network.players:
			if (id != 1):
				rpc_id(id, "_on_green_select", index)
	for p in Network.players:
		if Network.players[p].join_order == index:
			Network.players[p]["green"] = true
		else:
			Network.players[p]["green"] = false
	green_assigned = true
	if index == 0:
		green_assigned = false
	check_ready()

func _unhandled_input(event: InputEvent) -> void: # DEBUGGING
	if event.is_action_pressed("ui_cancel"):
		print(Network.players)
