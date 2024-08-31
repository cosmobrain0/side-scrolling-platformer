extends Button

var bus_to_change_name := "Sound Effects"
@onready var bus = AudioServer.get_bus_index(bus_to_change_name)

var previous_volume := 0.0
var min_volume := -24.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_volume_changed(AudioServer.get_bus_volume_db(bus))
	SignalBus.volume_changed.connect(_on_volume_changed)
	pressed.connect(_on_pressed)

func _on_volume_changed(new_volume: float) -> void:
	if new_volume == min_volume:
		AudioServer.set_bus_mute(bus, true)
		icon.current_frame = 0
	else:
		AudioServer.set_bus_mute(bus, false)
		icon.current_frame = 1
		previous_volume = new_volume

func _on_pressed() -> void:
	if AudioServer.get_bus_volume_db(bus) == min_volume:
		SignalBus.volume_changed.emit(previous_volume)
	else:
		SignalBus.volume_changed.emit(min_volume)
