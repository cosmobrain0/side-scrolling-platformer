extends Node

var high_score := 0.0
var current_score := 0.0
var score_increase_scene = preload("res://score_increase_indicator.tscn")

var combo := 0
const combo_cooldown := 2500
const combo_coefficient := 0.3
var previous_score_increase_time := -combo_cooldown

func _ready():
	SignalBus.game_restart.connect(_on_game_restart)
	SignalBus.score_changed.connect(_on_score_changed)
	SignalBus.player_health_changed.connect(_on_player_health_changed)

func _process(delta: float):
	var current_time := Time.get_ticks_msec()
	if current_time - previous_score_increase_time >= combo_cooldown:
		combo = 0

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
	if change > 0:
		combo += 1
		previous_score_increase_time = Time.get_ticks_msec()
	set_score(current_score + change * (1 + combo * combo_coefficient), position)

func _on_player_health_changed(old_health: float, new_health: float) -> void:
	if new_health < old_health:
		combo = 0
