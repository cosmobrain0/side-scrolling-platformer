extends Area2D

enum Facing {LEFT, RIGHT}

var speed := 500.0
var velocity: Vector2
var facing := Facing.LEFT
var destroyed := false
var particles_dead := false
@onready var particle_generator: CPUParticles2D = $CPUParticles2D
@onready var particlesAfterDeathTimer = $ParticlesAfterDeathTimer
@onready var sprite := $Sprite2D
@onready var animator := $AnimationPlayer

func direction() -> Vector2:
	if facing == Facing.LEFT: return Vector2.LEFT 
	else: return Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullets")
	SignalBus.bullet_spawned.connect(_on_bullet_spawn)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	velocity = speed * direction()
	particle_generator.direction = -direction()
	animator.play("spawn_in")
	SignalBus.game_restart.connect(_on_game_restart)

func _on_game_restart() -> void:
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if destroyed:
		if particles_dead: queue_free()
		return
	position += velocity * delta

func _on_body_entered(body: Node2D):
	destroy_self()

func destroy_self():
	destroyed = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	sprite.visible = false
	particle_generator.emitting = false
	particlesAfterDeathTimer.start()
	particlesAfterDeathTimer.timeout.connect(_on_destruction_timer_timeout)

func _on_destruction_timer_timeout():
	particles_dead = true

func _on_area_entered(area: Area2D):
	var script = area.get_script()
	if script != null:
		if script.get_global_name() == "Goomba": 
			SignalBus.goomba_shot.emit(self, area)
			destroy_self()
		elif script.get_global_name() == "ProjectileEnemy":
			SignalBus.projectile_enemy_shot.emit(area)
			destroy_self()

func _on_bullet_spawn(bullet: Node2D, bullet_facing: Facing):
	if bullet == self:
		set_facing(bullet_facing)

func set_facing(new_facing: Facing):
	facing = new_facing
	velocity = speed * direction()
	if facing == Facing.LEFT:
		sprite.frame = 1
	else:
		sprite.frame = 0
	particle_generator.direction = -direction()
