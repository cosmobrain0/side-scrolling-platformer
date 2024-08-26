extends Area2D

enum Facing {LEFT, RIGHT}

var speed := 250.0
var velocity: Vector2
var facing := Facing.LEFT
var destroyed := false
@onready var sprite := $Sprite2D

func direction() -> Vector2:
	if facing == Facing.LEFT: return Vector2.LEFT 
	else: return Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.bullet_spawned.connect(_on_bullet_spawn)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	velocity = speed * direction()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if destroyed:
		queue_free()
		return
	position += velocity * delta

func _on_body_entered(body: Node2D):
	destroyed = true

func _on_area_entered(area: Area2D):
	if area.get_script().get_global_name() == "Goomba":
		SignalBus.goomba_shot.emit(self, area)

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
