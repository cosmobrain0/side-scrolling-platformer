extends AnimatedSprite2D

enum Facing {LEFT, RIGHT}

var current_facing: Facing

func _ready():
	SignalBus.player_facing_changed.connect(_on_player_facing_changed)
	SignalBus.bullet_spawned.connect(_on_player_bullet_spawned)
	animation_finished.connect(_on_animation_finished)

func _on_player_facing_changed(new_facing: Facing) -> void:
	if new_facing == Facing.LEFT: animation = "look-left"
	else: animation = "look-right"
	current_facing = new_facing
	play()

func _on_player_bullet_spawned(_body: Node2D, facing: Facing):
	if facing == Facing.LEFT:
		animation = "shoot-left"
	else:
		animation = "shoot-right"
	current_facing = facing
	play()

func _on_animation_finished():
	if current_facing == Facing.LEFT: animation = "look-left"
	else: animation = "look-right"
	play()
