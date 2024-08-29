extends Control

@onready var timer := $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	SignalBus.health_increase_activated.connect(_on_health_increase_activated)
	timer.timeout.connect(_on_timer_timeout)

func _on_health_increase_activated():
	visible = true
	timer.paused = false
	timer.start()

func _on_timer_timeout():
	visible = false
