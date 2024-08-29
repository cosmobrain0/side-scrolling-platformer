extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var score := ScoreManager.high_score
	if score == 0:
		text = ""
	else:
		text = "Highscore: %s" % floorf(score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
