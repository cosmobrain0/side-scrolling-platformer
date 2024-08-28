extends CharacterBody2D

enum Facing {LEFT, RIGHT}

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -600.0
var facing := Facing.RIGHT
var bullet_scene := preload("res://bullet.tscn")

var can_shoot := true
var wants_to_shoot := false
var game_over := false
@onready var bullet_spawn_timer = $BulletSpawnTimer
var on_floor_last_frame := true

var health := 1.0
var goomba_damage := 0.2
var spike_damage := 0.4

var invincible := false
@onready var invincibility_timer = $InvincibilityTimer

func _ready():
	SignalBus.player_facing_changed.emit(Facing.RIGHT)
	SignalBus.goomba_collider_hit.connect(_on_goomba_collider_hit)
	SignalBus.spike_hit_player.connect(_on_spike_hit_player)
	bullet_spawn_timer.timeout.connect(_on_bullet_spawn_timer_timeout)
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)

func _on_bullet_spawn_timer_timeout():
	if wants_to_shoot:
		shoot_bullet()
	else: can_shoot = true

func shoot_bullet():
	can_shoot = false
	wants_to_shoot = false
	
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.position = position
	get_tree().root.add_child(bullet)
	SignalBus.bullet_spawned.emit(bullet, facing)
	bullet_spawn_timer.paused = false
	bullet_spawn_timer.start()

func _physics_process(delta: float) -> void:
	if game_over:
		SignalBus.game_restart.emit()
		get_tree().reload_current_scene()
		return
	
	if not on_floor_last_frame and is_on_floor():
		SignalBus.player_landed.emit(facing)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("game_shoot"):
		if can_shoot:
			shoot_bullet()
		else: wants_to_shoot = true

	# Handle jump.
	if Input.is_action_pressed("game_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		SignalBus.player_jumped.emit(facing)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("game_left", "game_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if direction > 0: set_facing(Facing.RIGHT)
		else: set_facing(Facing.LEFT)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	on_floor_last_frame = is_on_floor()
	move_and_slide()

func set_facing(new_facing: Facing) -> void:
	if new_facing != facing:
		facing = new_facing
		SignalBus.player_facing_changed.emit(facing)

func _on_goomba_collider_hit(player: Node2D) -> void:
	change_health(-goomba_damage)

func _on_spike_hit_player(spike: Area2D) -> void:
	change_health(-spike_damage)

func change_health(change: float) -> void:
	if not invincible:
		var old_health := health
		health = clampf(health + change, 0.0, 1.0)
		SignalBus.player_health_changed.emit(old_health, health)
		
		invincibility_timer.paused = false
		invincibility_timer.start()
		invincible = true
		SignalBus.player_invincible.emit()
		
		if health <= 0.0:
			game_over = true

func _on_invincibility_timer_timeout():
	invincible = false
	SignalBus.player_not_invincible.emit()
