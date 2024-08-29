class_name FireProjectile
extends Area2D

var angle := 0.0
var velocity: Vector2
const speed  := 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("projectiles")
	rotation = angle + PI / 2.0
	velocity = Vector2.from_angle(angle) * speed
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		print("Emitting signal")
		SignalBus.fire_projectile_hit_player.emit(self)
	queue_free()
