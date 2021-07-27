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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func set_ai() -> void:
	# ensure no ai in network game
	if not is_singleplayer:
		blue_ai = false
		red_ai = false
		green_ai = false
	# ai not supported for network in current builds
