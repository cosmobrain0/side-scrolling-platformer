extends CharacterBody2D

enum Facing {LEFT, RIGHT}

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -800.0
var facing := Facing.RIGHT

func _ready():
	SignalBus.player_facing_changed.emit(Facing.RIGHT)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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
