extends Node

signal server_created
signal join_success
signal join_fail
signal player_list_changed
signal player_removed(pinfo)

var game_started = false
var server_info = {
	server_name = "Server",
	max_players = 2,
	used_port = 0,
}
var players = {}

func _ready() -> void:
	if get_tree().connect("network_peer_connected", self, "_on_player_connected") != OK:
		push_error("network signal connect fail")
	if get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected") != OK:
		push_error("network signal connect fail")
	if get_tree().connect("connected_to_server", self, "_on_connected_to_server") != OK:
		push_error("network signal connect fail")
	if get_tree().connect("connection_failed", self, "_on_connection_failed") != OK:
		push_error("network signal connect fail")
	if get_tree().connect("server_disconnected", self, "_on_disconnected_from_server") != OK:
		push_error("network signal connect fail")

func create_server() -> void:
	var server = WebSocketServer.new()
	if server.listen(server_info.used_port, PoolStringArray(), true) != OK:
		push_error("Failed to create server")
		return
	get_tree().set_network_peer(server)
	emit_signal("server_created")
	# register server's player in the local player list
	register_player(Gamestate.player_info)

func _on_player_connected(_id) -> void:
	emit_signal("player_list_changed")

func _on_player_disconnected(id) -> void:
	print("Player ", players[id].player_name, " disconnected from server")
	# update the player tables
	if get_tree().is_network_server():
		# unregister player from server list
		unregister_player(id)
		# unregister on all remaining peers
		rpc("unregister_player", id)
	Gamestate.lost_connection_to_server()

func _on_disconnected_from_server() -> void:
	print("Disconnected from server")
	# clear internal player list
	players.clear()
	# reset the player info network ID
	Gamestate.player_info.net_id = 1
	Gamestate.lost_connection_to_server()

func join_server(ip, port) -> void:
	var client = WebSocketClient.new();
	var url = "ws://" + ip + ":" + str(port)
	# "ws://" for WebSocket connections
	if client.connect_to_url(url, PoolStringArray(), true) != OK:
		push_error("Failed to join server")
		emit_signal("join_fail")
		return
	get_tree().set_network_peer(client);

func _on_connected_to_server() -> void:
	emit_signal("join_success")
	# update player_info with obtained unique network ID
	Gamestate.player_info.net_id = get_tree().get_network_unique_id()
	# request server to register new player across all connected players
	rpc_id(1, "register_player", Gamestate.player_info)
	# register self on local list
	register_player(Gamestate.player_info)

func _on_connection_failed() -> void:
	emit_signal("join_fail")
	get_tree().set_network_peer(null)

remote func register_player(pinfo) -> void:
	if get_tree().is_network_server():
		# server distributes player list throughout connected players
		for id in players:
			# Send currently iterated player info to the new player
			rpc_id(pinfo.net_id, "register_player", players[id])
			# Send new player info to currently iterated player, skipping server until later
			if (id != 1):
				rpc_id(id, "register_player", pinfo)
	# executed on both client or server
	print("Registering player ", pinfo.player_name, " (", pinfo.net_id, ") to internal player table")
	players[pinfo.net_id] = pinfo      # create player entry in player list
	var values = players.keys()
	values.sort()
	var i = 1
	for p in values:
		players[p]["join_order"] = i
		i += 1
	emit_signal("player_list_changed") # notify that the player list has been changed

remote func update_player() -> void:
	if get_tree().is_network_server():
		register_player(Gamestate.player_info)
	else:
		rpc_id(1, "register_player", Gamestate.player_info)

remote func unregister_player(id) -> void:
	print("Removing player ", players[id].player_name, " from internal table")
	var pinfo = players[id]
	players.erase(id)
	# notify list has been changed
	emit_signal("player_list_changed")
	emit_signal("player_removed", pinfo)
