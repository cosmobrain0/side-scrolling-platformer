class_name Goomba
extends Area2D

enum Facing {LEFT, RIGHT}

var speed := 80.0
var facing := Facing.LEFT
var ground_check_offset := Vector2(16, 0)
var wall_check_target_offset := Vector2(18, 0)
var destroyed := false
var death_animation_complete := false
var death_animation_name = "die"

@onready var ground_check: RayCast2D = $GroundCheck
@onready var wall_check: RayCast2D = $WallCheck
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var destructor_area: Area2D = $Destructor
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	destructor_area.body_entered.connect(_on_destructor_body_entered)
	SignalBus.goomba_shot.connect(_on_goomba_shot)
	animated_sprite.play()

func direction() -> Vector2:
	if facing == Facing.LEFT: return Vector2.LEFT
	else: return Vector2.RIGHT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if destroyed:
		death_animation_player.advance(delta)
		if death_animation_complete: queue_free()
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
	if body.name == "Player" and not destroyed:
		SignalBus.goomba_bounced_on.emit(body)
		ScoreManager.change_score(213, global_position)
		destroy()

func _on_goomba_shot(bullet: Node2D, goomba: Area2D):
	if goomba == self and not destroyed:
		ScoreManager.change_score(132, global_position)
		destroy()

func destroy():
	destroyed = true
	animated_sprite.animation = "dying"
	death_animation_player.play(death_animation_name)
	death_animation_player.animation_finished.connect(_queue_for_free)

func _queue_for_free(name: String):
	if death_animation_name == name:
		death_animation_complete = true
