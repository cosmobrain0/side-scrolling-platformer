extends Node

enum Facing {LEFT, RIGHT}

var high_score := 0.0
var current_score := 0.0

func _ready():
	game_restart.connect(_on_game_restart)
	score_changed.connect(_on_score_changed)

signal player_facing_changed(facing: Facing)
signal player_jumped(facing: Facing)
signal player_landed(facing: Facing)
signal goomba_collider_hit(player: Node2D)
signal goomba_bounced_on(player: Node2D)
signal bullet_spawned(bullet: Node2D, facing: Facing)
signal goomba_shot(bullet: Node2D, goomba: Area2D)
signal game_restart()
signal spike_hit_player(spike: Node2D)
signal player_health_changed(old_health: float, new_health: float)
signal camera_moved(old_position: Vector2, new_position: Vector2)
signal player_invincible()
signal player_not_invincible()
signal player_lost()
signal score_changed(old_score: float, new_score: float)

func _on_game_restart() -> void:
	high_score = maxf(current_score, high_score)
	current_score = 0.0

func _on_score_changed(old_score: float, new_score: float) -> void:
	current_score = new_score

func set_score(new_score: float) -> void:
	var old_score: float = SignalBus.current_score
	if new_score != old_score:
		SignalBus.score_changed.emit(old_score, new_score)

func change_score(change: float) -> void:
	set_score(current_score + change)
