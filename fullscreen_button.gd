extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	SignalBus.full_screen_set.connect(_on_fullscreen_set)
	SignalBus.full_screen_unset.connect(_on_fullscreen_unset)
	visible = not FullScreen.fullscreen

func _on_fullscreen_unset():
	visible = true

func _on_fullscreen_set():
	visible = false

func _on_pressed():
	FullScreen.set_fullscreen()
	$"../UnFullscreenButton".visible = true
	visible = false
