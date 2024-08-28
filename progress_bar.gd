extends ProgressBar

var original_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = position
	SignalBus.player_health_changed.connect(_on_player_health_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_health_changed(old_health: float, new_health: float) -> void:
	value = clampf(new_health, 0, 1)
