extends Area2D

var sound_effect_complete := false
@onready var audio_player = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		ScoreManager.change_score(50, global_position)
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		visible = false
		audio_player.play()
		audio_player.finished.connect(_on_audio_finished)

func _on_audio_finished():
	sound_effect_complete = true
	queue_free()
