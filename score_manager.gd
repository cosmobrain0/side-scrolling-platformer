extends Node

var high_score := 0.0
var current_score := 0.0

func _ready():
	SignalBus.game_restart.connect(_on_game_restart)
	SignalBus.score_changed.connect(_on_score_changed)

func _on_game_restart() -> void:
	high_score = maxf(current_score, high_score)
	current_score = 0.0

func _on_score_changed(old_score: float, new_score: float) -> void:
	current_score = new_score

func set_score(new_score: float) -> void:
	var old_score: float = current_score
	if new_score != old_score:
		SignalBus.score_changed.emit(old_score, new_score)

func change_score(change: float) -> void:
	set_score(current_score + change)
