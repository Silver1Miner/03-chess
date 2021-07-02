extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	if Network.connect("server_created", self, "_on_ready_to_play") != OK:
		push_error("server signal connect fail")
