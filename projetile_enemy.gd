class_name ProjectileEnemy
extends Area2D

var projectile_scene := preload("res://fire_projectile.tscn")
@onready var shoot_timer := $ShootTimer
@onready var animated_sprite := $AnimatedSprite2D

var destroyed := false
var death_animation_complete := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.projectile_enemy_shot.connect(_on_projectile_enemy_shot)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_shoot_timer_timeout() -> void:
	if destroyed:
		return
	var projectile: FireProjectile = projectile_scene.instantiate()
	projectile.angle = 0
	projectile.position = global_position
	get_tree().root.add_child(projectile)
	
	projectile = projectile_scene.instantiate()
	projectile.angle = PI
	projectile.position = global_position
	get_tree().root.add_child(projectile)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SignalBus.projectile_enemy_hit.emit(self)

func _on_projectile_enemy_shot(projectile_enemy: Area2D) -> void:
	if projectile_enemy == self:
		destroyed = true
		animated_sprite.play("die")
		animated_sprite.animation_finished.connect(_on_death_animation_complete)

func _on_death_animation_complete() -> void:
	queue_free()
