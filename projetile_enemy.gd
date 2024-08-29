extends Area2D

var projectile := preload("res://fire_projectile.tscn")
@onready var shoot_timer := $ShootTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_shoot_timer_timeout() -> void:
	print("Hi there")
	var projectile: FireProjectile = projectile.instantiate()
	projectile.angle = 0
	projectile.position = global_position
	get_tree().root.add_child(projectile)
