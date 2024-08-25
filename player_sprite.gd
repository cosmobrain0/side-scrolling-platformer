extends Sprite2D

enum Facing {LEFT, RIGHT}

func _ready():
	SignalBus.player_facing_changed.connect(_on_player_facing_changed)

func _on_player_facing_changed(new_facing: Facing) -> void:
	if new_facing == Facing.LEFT: frame = 1
	else: frame = 0
