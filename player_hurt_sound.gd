extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_player_health_changed(old_health: float, new_health: float) -> void:
	if old_health > new_health:
		play()
