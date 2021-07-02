extends Node

var server_info = {
	server_name = "Server",
	max_players = 0,
	used_port = 0,
}

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
	var net = WebSocketServer.new()
	if (net.create_server(server_info.used_port, server_info.max_players) != OK):
		push_error("Failed to create server")
		return
	get_tree().set_network_peer(net)
	emit_signal("server_created")
