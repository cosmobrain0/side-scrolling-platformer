extends RichTextLabel

var current_score := 0.0
var target_score := 0.0
var score_update_speed = 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.score_changed.connect(_on_score_changed)
	update_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var change := target_score - current_score
	if change == 0.0:
		update_text()
		return
	change *= minf(score_update_speed * delta, abs(change)) / abs(change)
	set_current_score(current_score + change)

func _on_score_changed(old_score: float, new_score: float, position: Vector2) -> void:
	target_score = new_score

func set_current_score(new_score: float):
	current_score = new_score
	update_text()

func update_text():
	var delta := target_score - current_score
	var score_format: String
	if delta == 0:
		score_format = "[b]Score[/b]: %s"
	else:
		score_format = "[b]Score[/b]: [color=green]%s[/color]"
	var score_text = score_format % str(floorf(current_score))
	var high_score_text = "[b]High Score[/b]: %s" % str(floorf(ScoreManager.high_score))
	var combo_text := ""
	if ScoreManager.combo > 0:
		combo_text = "(x%s)" % ScoreManager.combo
	text = "%s %s\n%s" % [score_text, combo_text, high_score_text]
