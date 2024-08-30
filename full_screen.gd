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
			SignalBus.full_screen_unset.emit()
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
			SignalBus.full_screen_set.emit()

func set_fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	fullscreen = true
	SignalBus.full_screen_set.emit()

func set_unfullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen = false
	SignalBus.full_screen_unset.emit()
