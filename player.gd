extends CharacterBody2D

enum Facing {LEFT, RIGHT}

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -800.0
var facing := Facing.RIGHT
var bullet_scene := preload("res://bullet.tscn")

var game_over := false

func _ready():
	SignalBus.player_facing_changed.emit(Facing.RIGHT)
	SignalBus.goomba_collider_hit.connect(_on_goomba_collider_hit)

func _physics_process(delta: float) -> void:
	if game_over:
		get_tree().reload_current_scene()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("game_shoot"):
		# TODO: add a timer so that the player can't shoot too fast
		# TODO: add some sort of animation system
		var bullet: Node2D = bullet_scene.instantiate()
		bullet.position = position
		get_tree().root.add_child(bullet)
		SignalBus.bullet_spawned.emit(bullet, facing)

	# Handle jump.
	if Input.is_action_pressed("game_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("game_left", "game_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if direction > 0: set_facing(Facing.RIGHT)
		else: set_facing(Facing.LEFT)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func set_facing(new_facing: Facing) -> void:
	if new_facing != facing:
		facing = new_facing
		SignalBus.player_facing_changed.emit(facing)

func _on_goomba_collider_hit(player: Node2D) -> void:
	game_over = true
