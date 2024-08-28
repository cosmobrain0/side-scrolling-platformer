extends AnimatedSprite2D

enum Facing {LEFT, RIGHT}

var current_facing: Facing
const normal_modulation := Color(1, 1, 1)
const red_modulation := Color(1.5, 0.509, 0.509)
@onready var modulation_timer := $ModulateSwapTimer
var modulated := false

func _ready():
	SignalBus.player_facing_changed.connect(_on_player_facing_changed)
	SignalBus.bullet_spawned.connect(_on_player_bullet_spawned)
	SignalBus.player_jumped.connect(_on_player_jumped)
	SignalBus.player_landed.connect(_on_player_landed)
	SignalBus.player_invincible.connect(_on_player_invincible)
	SignalBus.player_not_invincible.connect(_on_player_not_invincible)
	modulation_timer.timeout.connect(_on_modulation_timer_tick)
	animation_finished.connect(_on_animation_finished)

func _on_player_facing_changed(new_facing: Facing) -> void:
	if new_facing == Facing.LEFT: animation = "look-left"
	else: animation = "look-right"
	current_facing = new_facing
	frame = 0
	play()

func _on_player_jumped(new_facing: Facing) -> void:
	if new_facing == Facing.RIGHT: animation = "jump-right"
	else: animation = "jump-left"
	current_facing = new_facing
	frame = 0
	play()

func _on_player_landed(new_facing: Facing) -> void:
	if new_facing == Facing.RIGHT: animation = "land-right"
	else: animation = "land-left"
	current_facing = new_facing
	frame = 0
	play()

func _on_player_bullet_spawned(_body: Node2D, facing: Facing):
	if facing == Facing.LEFT:
		animation = "shoot-left"
	else:
		animation = "shoot-right"
	current_facing = facing
	frame = 0
	play()

func _on_animation_finished():
	if current_facing == Facing.LEFT: animation = "look-left"
	else: animation = "look-right"
	play()

func _on_player_invincible():
	set_modulated(true)
	modulation_timer.paused = false
	modulation_timer.start()

func _on_modulation_timer_tick():
	set_modulated(not modulated)

func _on_player_not_invincible():
	modulation_timer.paused = true
	set_modulated(false)

func set_modulated(new_modulated: bool) -> void:
	modulated = new_modulated
	if modulated: modulate = red_modulation
	else: modulate = normal_modulation
