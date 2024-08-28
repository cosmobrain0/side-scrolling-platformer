extends TextureButton

@onready var pause_menu := $"../PauseMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _process(delta: float) -> void:
	if get_tree().paused:
		print("paused")
	else:
		print("playing")

func _on_pressed():
	var new_paused := not get_tree().paused
	print(new_paused)
	get_tree().paused = new_paused
	pause_menu.visible = new_paused
