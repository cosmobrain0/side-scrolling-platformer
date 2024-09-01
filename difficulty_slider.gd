extends VSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = DifficultyManager.difficulty
	value_changed.connect(_on_value_changed)


func _on_value_changed(new_value: float) -> void:
	DifficultyManager.difficulty = new_value
