extends Node

var is_singleplayer := true
var player_info = {
	player_name = "Player",
	net_id = 1,
	join_order = 1,
	blue = false,
	red = false,
	green = false
}
var style = "W" # W or E
var board_style = "marble" # marble, wood, land
var blue_ai = false
var red_ai = false
var green_ai = false

signal connection_lost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func reset_ai() -> void:
	blue_ai = false
	red_ai = false
	green_ai = false

func lost_connection_to_server() -> void:
	emit_signal("connection_lost")
