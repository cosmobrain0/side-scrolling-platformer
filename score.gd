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
	if change == 0.0: return
	change *= minf(score_update_speed * delta, abs(change)) / abs(change)
	set_current_score(current_score + change)

func _on_score_changed(old_score: float, new_score: float, position: Vector2) -> void:
	target_score = new_score

func set_current_score(new_score: float):
	current_score = new_score
	update_text()

func update_text():
	if target_score != current_score:
		var delta := target_score - current_score
		var format: String
		if delta == 0:
			format = "[b]Score[/b]: %s\n[b]High Score[/b]: %s"
		else:
			format = "[b]Score[/b]: [color=green]%s[/color]\n[b]High Score[/b]: %s"
		text = format % [str(floorf(current_score)), str(floorf(ScoreManager.high_score))]
	else: text = "[b]Score[/b]: %s\n[b]High Score[/b]: %s" % [str(floorf(current_score)), str(floorf(ScoreManager.high_score))]
