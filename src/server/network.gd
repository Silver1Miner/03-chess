extends Node

signal server_created
signal join_success
signal join_fail
#signal player_list_changed

var server_info = {
	server_name = "Server",
	max_players = 0,
	used_port = 0,
}
var players = {}

func _ready():
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
	#if (server.create_server(server_info.used_port, server_info.max_players) != OK):
	#	push_error("Failed to create server")
	#	return
	get_tree().set_network_peer(server)
	emit_signal("server_created")

func _on_player_connected(_id) -> void:
	pass

func _on_player_disconnected(_id) -> void:
	pass

func join_server(ip, port):
	var client = WebSocketClient.new();
	var url = "ws://" + ip + ":" + str(port)
	# "ws://" for WebSocket connections
	if client.connect_to_url(url, PoolStringArray(), true) != OK:
		push_error("Failed to join server")
		emit_signal("join_fail")
		return
	get_tree().set_network_peer(client);

func _on_connected_to_server():
	emit_signal("join_success")

func _on_connection_failed():
	emit_signal("join_fail")
	get_tree().set_network_peer(null)
