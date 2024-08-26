extends Node

var fullscreen: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fullscreen = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreen = false
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
