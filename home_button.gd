extends TextureButton

@onready var game := load("res://main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	SignalBus.leaving_game.emit()
	get_tree().change_scene_to_packed(game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
