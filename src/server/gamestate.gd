extends Node

var is_singleplayer := true
var player_info = {
	player_name = "Player",
	net_id = 1,
	actor_path = "res://src/world/player/player.tscn",
	char_color = Color(1, 1, 1),
	spawn_cell = Vector2(0, 0)
}

var whose_turn := 1 # 1 blue 2 red 3 green
var turn_count := 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
