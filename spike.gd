extends Area2D

var hitting_player := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hitting_player:
		SignalBus.spike_hit_player.emit(self)

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		hitting_player = true

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		hitting_player = false
