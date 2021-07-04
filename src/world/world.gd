extends Node2D

onready var player_name = $HUD/Label
onready var hud_player_list = $HUD/playerlist

# Called when the node enters the scene tree for the first time.
func _ready():
	if Network.connect("player_list_changed", self, "_on_player_list_changed") != OK:
		push_error("player list change signal connect fail")
	# display the local player name
	player_name.text = Gamestate.player_info.player_name

func _on_player_list_changed():
	# remove all children from hud list
	for c in hud_player_list.get_children():
		c.queue_free()
	# iterate through player list creating new entries
	for p in Network.players:
		if (p != Gamestate.player_info.net_id):
			var nlabel = Label.new()
			nlabel.text = Network.players[p].player_name
			hud_player_list.add_child(nlabel)
