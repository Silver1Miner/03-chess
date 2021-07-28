extends Node2D # world.gd The gameworld

onready var player_name = $HUD/Label
onready var hud_player_list = $HUD/playerlist
onready var board = $board
onready var menu_button = $game_display/menu_button
onready var game_state_label = $game_display/game_state
onready var move_log = $game_display/move_log
export var grid: Resource = preload("res://src/world/board/Grid.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	if Gamestate.connect("connection_lost", self, "_on_connection_lost") != OK:
		push_error("connection signal fail")
	if board.connect("endgame_change", self, "_on_endgame_change") != OK:
		push_error("endgame signal connect fail")
	if board.connect("move_log_change", self, "_on_move_log_change") != OK:
		push_error("move log signal connect fail")
	$connect_lost.visible = false
	if board.connect("whose_turn", self, "_on_turn_change") != OK:
		push_error("turn connect fail")
	if menu_button.connect("pressed", self, "_on_menu_button_pressed") != OK:
		push_error("menu button connect fail")
	if !Gamestate.is_singleplayer:
		if Network.connect("player_list_changed", self, "_on_player_list_changed") != OK:
			push_error("player list change signal connect fail")
		if get_tree().is_network_server():
			if Network.connect("player_removed", self, "_on_player_removed") != OK:
				push_error("player remove signal connect fail")
		# display local player name
		#player_name.text = Gamestate.player_info.player_name
		#if (get_tree().is_network_server()):
		#	spawn_players(Gamestate.player_info, 1)
		#else:
		#	rpc_id(1, "spawn_players", Gamestate.player_info, -1)
	else:
		spawn_singleplayer()
	move_log.push_table(3)

func _on_connection_lost() -> void:
	$connect_lost.visible = true

func _on_endgame_change(endgame_state) -> void:
	game_state_label.text = endgame_state

var move_number = 1
func _on_move_log_change(new_move) -> void:
	move_log.push_cell()
	move_log.add_text(str(move_number) + "." + new_move + "  ")
	move_log.pop()
	move_number += 1

func _on_menu_button_pressed() -> void:
	Gamestate.reset_ai()
	Network._on_connection_failed()
	if get_tree().change_scene("res://src/menu/menu.tscn") != OK:
		push_error("main menu change fail")

func _on_turn_change(turn) -> void:
	$game_display/whose_turn.text = "Turn: " + turn

func _on_player_list_changed() -> void:
	# remove all children from hud list
	for c in hud_player_list.get_children():
		c.queue_free()
	# iterate through player list creating new entries
	for p in Network.players:
		if (p != Gamestate.player_info.net_id):
			var nlabel = Label.new()
			nlabel.text = Network.players[p].player_name
			hud_player_list.add_child(nlabel)

func _on_player_removed(pinfo) -> void:
	despawn_player(pinfo)

remote func spawn_players(pinfo, spawn_index) -> void:
	if (spawn_index == -1):
		spawn_index = Network.players.size()
	if (get_tree().is_network_server() && pinfo.net_id != 1):
		var s_index = 1
		for id in Network.players:
			# Spawn currently iterated player in the new player's scene, skip new player for now
			if (id != pinfo.net_id):
				rpc_id(pinfo.net_id, "spawn_players", Network.players[id], s_index)
			# Spawn new player within the currently iterated player as long it's not the server
			# Because the server's list already contains the new player, that one will also get itself!
			if (id != 1):
				rpc_id(id, "spawn_players", pinfo, spawn_index)
			s_index += 1
	# Load the scene and create an instance
	var pclass = load(pinfo.actor_path)
	var nactor = pclass.instance()
	nactor.is_singleplayer = false
	# And the actor position
	nactor.position = grid.calculate_map_position(pinfo.spawn_cell)
	# If this actor does not belong to the server, change the node name and network master accordingly
	if (pinfo.net_id != 1):
		nactor.set_network_master(pinfo.net_id)
	nactor.set_name(str(pinfo.net_id))
	# Finally add the actor into the world
	board.add_child(nactor)

remote func despawn_player(pinfo) -> void:
	if (get_tree().is_network_server()):
		for id in Network.players:
			# Skip disconnected player and server from replication
			if (id == pinfo.net_id || id == 1):
				continue
			# Replicate despawn into currently iterated player
			rpc_id(id, "despawn_player", pinfo)
	# locate the player actor
	#var player_node = get_node(str(pinfo.net_id))
	#if (!player_node):
	#	print("Cannot remove invalid node from tree")
	#	return
	#player_node.queue_free()

func spawn_singleplayer() -> void:
	pass
	#var pclass = load("res://src/world/player/player.tscn")
	#var nactor = pclass.instance()
	#nactor.is_singleplayer = true
	#nactor.position = Vector2(0, 0)
	#board.add_child(nactor)
