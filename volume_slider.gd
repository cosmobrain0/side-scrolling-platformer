extends HSlider

var bus_to_change_name := "Sound Effects"
@onready var bus = AudioServer.get_bus_index(bus_to_change_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value_changed.connect(_on_value_changed)
	SignalBus.volume_changed.connect(_on_volume_changed)
	value = AudioServer.get_bus_volume_db(bus)

func _on_value_changed(new_value: float):
	SignalBus.volume_changed.emit(value)

func _on_volume_changed(new_volume: float) -> void:
	set_value_no_signal(new_volume)
	AudioServer.set_bus_volume_db(bus, value)
