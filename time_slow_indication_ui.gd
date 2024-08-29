extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	SignalBus.time_slow_activated.connect(_on_time_slow_activate)
	SignalBus.time_slow_deactivated.connect(_on_time_slow_deactivate)

func _on_time_slow_activate():
	visible = true

func _on_time_slow_deactivate():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
