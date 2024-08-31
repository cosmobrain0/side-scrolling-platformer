extends Area2D

var score_increase_indicator_scene = preload("res://score_increase_indicator.tscn")
var picked_up := false
@onready var audio_player := $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("power-ups")
	body_entered.connect(_on_body_entered)
	SignalBus.game_restart.connect(_on_game_restart)
	audio_player.finished.connect(_on_picked_up_audio_finished)

func _on_game_restart() -> void:
	queue_free()

func _on_body_entered(body: Node2D):
	if body.name == "Player" and not picked_up:
		SignalBus.health_increase_activated.emit()
		var scene: ScoreIncreaseIndicator = score_increase_indicator_scene.instantiate()
		scene.global_position = global_position + Vector2(32, -32)
		scene.score_value = "❤️"
		get_tree().root.add_child(scene)
		audio_player.play()
		visible = false

func _on_picked_up_audio_finished():
	queue_free()
