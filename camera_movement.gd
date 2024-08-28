extends Node2D

enum Facing {LEFT, RIGHT}

var levels: Array[Resource] = [preload("res://levels/level-0.tscn"), preload("res://levels/level-1.tscn")]
var previous_level_index = -1
@onready var previous_scene: TileMapLayer = null
@onready var current_scene: TileMapLayer = $TileMapLayer
@onready var next_scene: TileMapLayer
@onready var player := $Player
var camera_origin := Vector2.ZERO
var movement_speed := 200.0
var left_bound_for_player := -50.0

@onready var camera_origin_x_at_last_level_spawn := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_scene = create_next_level()
	next_scene.position = Vector2(1920, 0)
	get_tree().root.add_child.call_deferred(next_scene)
	SignalBus.game_restart.connect(_on_game_restart)
	SignalBus.leaving_game.connect(_on_leaving_game)

func create_next_level() -> TileMapLayer:
	var level_index := randi() % levels.size()
	if level_index == previous_level_index:
		level_index = (level_index + 1) % levels.size()
	previous_level_index = level_index
	next_scene = levels[level_index].instantiate()
	return next_scene

func _on_game_restart():
	if previous_scene != null: previous_scene.queue_free()
	current_scene.queue_free()
	next_scene.queue_free()
	set_origin(Vector2(0, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_origin(camera_origin - Vector2(movement_speed * delta, 0))
	if player.global_position.x + camera_origin.x >= 1200:
		set_origin(camera_origin - Vector2(player.global_position.x + camera_origin.x - 1200, 0))
	if player.global_position.x <= -camera_origin.x + left_bound_for_player:
		SignalBus.game_restart.emit()
		get_tree().reload_current_scene()
		return
	if camera_origin_x_at_last_level_spawn + 1700 <= -camera_origin.x:
		if previous_scene != null:
			previous_scene.queue_free()
		previous_scene = current_scene
		current_scene = next_scene
		next_scene = create_next_level()
		previous_scene.position -= Vector2(1920, 0)
		current_scene.position -= Vector2(1920, 0)
		next_scene.position = Vector2(1920, 0)
		player.position -= Vector2(1920, 0)
		set_origin(camera_origin + Vector2(1920, 0))
		get_tree().root.add_child.call_deferred(next_scene)

func set_origin(new_origin: Vector2) -> void:
	var changed := camera_origin != new_origin
	var old_origin := camera_origin	
	camera_origin = new_origin
	get_viewport().set_canvas_transform(Transform2D(0, camera_origin))
	if changed:
		SignalBus.camera_moved.emit(-old_origin, -camera_origin)

func _on_leaving_game():
	if previous_scene != null: previous_scene.queue_free()
	current_scene.queue_free()
	next_scene.queue_free()
	set_origin(Vector2.ZERO)
