extends CharacterBody2D

enum Facing {LEFT, RIGHT}

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -600.0
var facing := Facing.RIGHT
var bullet_scene := preload("res://bullet.tscn")

var can_shoot := true
var wants_to_shoot := false
var player_lost := false
var game_over := false
@onready var animation_player = $AnimationPlayer
@onready var bullet_spawn_timer = $BulletSpawnTimer
var on_floor_last_frame := true

var health := 1.0
const goomba_damage := 0.2
const spike_damage := 0.4
const fire_projectile_damage := 0.2

var invincible := false
@onready var invincibility_timer = $InvincibilityTimer

var being_pushed_back := false
@onready var push_back_timer = $PushBackTimer
var push_back_direction: Facing
const push_back_force := 300.0
const push_back_jump_force := -100.0

func _ready():
	SignalBus.player_facing_changed.emit(Facing.RIGHT)
	SignalBus.goomba_collider_hit.connect(_on_goomba_collider_hit)
	SignalBus.spike_hit_player.connect(_on_spike_hit_player)
	SignalBus.fire_projectile_hit_player.connect(_on_fire_projectile_hit_player)
	bullet_spawn_timer.timeout.connect(_on_bullet_spawn_timer_timeout)
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	push_back_timer.timeout.connect(_on_push_back_timer_timeout)

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
	if player_lost:
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
	
	if being_pushed_back:
		if push_back_direction == Facing.LEFT:
			set_facing(Facing.RIGHT)
			velocity.x = -push_back_force
		else:
			set_facing(Facing.LEFT)
			velocity.x = push_back_force

	on_floor_last_frame = is_on_floor()
	move_and_slide()

func set_facing(new_facing: Facing) -> void:
	if new_facing != facing:
		facing = new_facing
		SignalBus.player_facing_changed.emit(facing)

func _on_goomba_collider_hit(player: Node2D) -> void:
	change_health(-goomba_damage, opposite_facing(facing))

func _on_fire_projectile_hit_player(projectile: Area2D) -> void:
	print("Received signal: %s" % -fire_projectile_damage)
	var direction := Facing.RIGHT
	if projectile.global_position.x > global_position.x:
		direction = Facing.LEFT
	change_health(-fire_projectile_damage, direction)

func _on_spike_hit_player(spike: Area2D) -> void:
	change_health(-spike_damage, opposite_facing(facing))

func opposite_facing(facing: Facing) -> Facing:
	if facing == Facing.LEFT: return Facing.RIGHT
	else: return Facing.LEFT

func change_health(change: float, push_back_direction: Facing) -> void:
	if not invincible:
		var old_health := health
		health = clampf(health + change, 0.0, 1.0)
		SignalBus.player_health_changed.emit(old_health, health)
		
		invincibility_timer.paused = false
		invincibility_timer.start()
		invincible = true
		SignalBus.player_invincible.emit()
		
		self.push_back_direction = push_back_direction
		being_pushed_back = true
		push_back_timer.paused = false
		push_back_timer.start()
		velocity.y = push_back_jump_force
		
		if health <= 0.0:
			set_player_lost_true()

func set_player_lost_true():
	player_lost = true
	SignalBus.player_lost.emit()
	# animated_sprite.animation = "dying"
	animation_player.play("die")
	animation_player.animation_finished.connect(_on_game_over)

func _on_game_over(name: String):
	if name == "die": game_over = true

func _on_invincibility_timer_timeout():
	invincible = false
	SignalBus.player_not_invincible.emit()

func _on_push_back_timer_timeout():
	being_pushed_back = false
