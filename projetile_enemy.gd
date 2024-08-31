class_name ProjectileEnemy
extends Area2D

var time_slow_scene := preload("res://power-up-slow-camera.tscn")
var health_increase_scene := preload("res://health_increase_power_up.tscn")

var projectile_scene := preload("res://fire_projectile.tscn")
@onready var shoot_timer := $ShootTimer
@onready var animated_sprite := $AnimatedSprite2D
@onready var audio_player := $AudioStreamPlayer2D

var destroyed := false
var death_animation_complete := false
var death_audio_complete := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.projectile_enemy_shot.connect(_on_projectile_enemy_shot)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if destroyed and death_animation_complete and death_audio_complete: queue_free()

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
	if body.name == "Player" and not destroyed:
		SignalBus.projectile_enemy_hit.emit(self)

func _on_projectile_enemy_shot(projectile_enemy: Area2D) -> void:
	if projectile_enemy == self and not destroyed:
		var random_number := randf()
		if random_number <= 0.1:
			var scene: Area2D = time_slow_scene.instantiate()
			scene.position = global_position
			get_tree().root.call_deferred("add_child", scene)
		elif random_number <= 0.2:
			var scene: Area2D = health_increase_scene.instantiate()
			scene.position = global_position
			get_tree().root.call_deferred("add_child", scene)
		destroyed = true
		animated_sprite.play("die")
		animated_sprite.animation_finished.connect(_on_death_animation_complete)
		audio_player.play()
		audio_player.finished.connect(_on_death_audio_complete)
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		

func _on_death_animation_complete() -> void:
	death_animation_complete = false

func _on_death_audio_complete() -> void:
	death_audio_complete = true
