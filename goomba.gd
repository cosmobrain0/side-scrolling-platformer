extends Area2D

enum Facing {LEFT, RIGHT}

var speed := 80.0
var facing := Facing.LEFT
var ground_check_offset := Vector2(16, 0)
var wall_check_target_offset := Vector2(18, 0)
var destroyed := false

@onready var ground_check: RayCast2D = $GroundCheck
@onready var wall_check: RayCast2D = $WallCheck
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var destructor_area: Area2D = $Destructor
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	destructor_area.body_entered.connect(_on_destructor_body_entered)
	animated_sprite.play()

func direction() -> Vector2:
	if facing == Facing.LEFT: return Vector2.LEFT
	else: return Vector2.RIGHT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if destroyed:
		queue_free()
		return
	var velocity := Vector2.ZERO
	var ground := ground_check.is_colliding()
	var wall := wall_check.is_colliding()
	if ground:
		if wall:
			turn_around()
		velocity = speed * delta * direction()
	else:
		turn_around()
	
	position += velocity

func turn_around() -> void:
	if facing == Facing.LEFT: set_facing(Facing.RIGHT)
	else: set_facing(Facing.LEFT)

func set_facing(new_facing: Facing) -> void:
	facing = new_facing
	if facing == Facing.RIGHT:
		ground_check.position = ground_check_offset
		wall_check.target_position = wall_check_target_offset
		animated_sprite.animation = "walking-right"
	else:
		ground_check.position = Vector2(-ground_check_offset.x, ground_check_offset.y)
		wall_check.target_position = Vector2(-wall_check_target_offset.x, wall_check_target_offset.y)
		animated_sprite.animation = "walking-left"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" && !destroyed:
		SignalBus.goomba_collider_hit.emit(body)

func _on_destructor_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SignalBus.goomba_bounced_on.emit(body)
		destroyed = true
