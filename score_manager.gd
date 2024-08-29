extends Node

var high_score := 0.0
var current_score := 0.0
var score_increase_scene = preload("res://score_increase_indicator.tscn")

func _ready():
	SignalBus.game_restart.connect(_on_game_restart)
	SignalBus.score_changed.connect(_on_score_changed)

func _on_game_restart() -> void:
	high_score = maxf(current_score, high_score)
	current_score = 0.0

func _on_score_changed(old_score: float, new_score: float, position: Vector2) -> void:
	current_score = new_score
	var scene: ScoreIncreaseIndicator = score_increase_scene.instantiate()
	scene.position = position
	scene.score_value = new_score - old_score
	get_tree().root.add_child(scene)

func set_score(new_score: float, position: Vector2) -> void:
	var old_score: float = current_score
	if new_score != old_score:
		SignalBus.score_changed.emit(old_score, new_score, position)

func change_score(change: float, position: Vector2) -> void:
	set_score(current_score + change, position)
