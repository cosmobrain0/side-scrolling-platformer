class_name ScoreIncreaseIndicator
extends Control

var score_value: float
@onready var label = $Label
@onready var animation_player = $Label/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "+%s" % str(floorf(score_value))
	animation_player.play("fade_upwards")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(name: String):
	queue_free()
