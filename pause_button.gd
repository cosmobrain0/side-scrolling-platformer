extends TextureButton

@onready var pause_menu := $"../PauseMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	var new_paused := not get_tree().paused
	get_tree().paused = new_paused
	pause_menu.visible = new_paused
