extends AudioStreamPlayer

var move = preload("res://assets/sounds/footstep02.ogg")
var check = preload("res://assets/sounds/knifeSlice.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_move() -> void:
	stream = move
	play()

func play_check() -> void:
	stream = check
	play()
