extends Node2D

enum Facing {LEFT, RIGHT}

var levels: Array[Resource] = [preload("res://levels/level-0.tscn"), preload("res://levels/level-1.tscn"), preload("res://levels/level-2.tscn")]
var previous_level_index = -1
@onready var previous_scene: TileMapLayer = null
@onready var current_scene: TileMapLayer = $TileMapLayer
@onready var next_scene: TileMapLayer
@onready var player := $Player
var camera_origin := Vector2.ZERO
var camera_transform := Transform2D(0, camera_origin)
const normal_movement_speed := 200.0
const slow_movement_speed := 50.0
var movement_speed := normal_movement_speed
var left_bound_for_player := -50.0
var time_of_time_slow := 0.0

var movement_speed_multiplier = 0.0
const movement_speed_multiplier_increase = 0.25
var movement_started := false

func time_slow_active() -> bool:
	return movement_speed == slow_movement_speed

@onready var camera_origin_x_at_last_level_spawn := 0.0
@onready var time_slow_timer := $TimeSlowTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_scene = create_next_level()
	next_scene.position = Vector2(1920, 0)
	get_tree().root.add_child.call_deferred(next_scene)
	SignalBus.game_restart.connect(_on_game_restart)
	SignalBus.leaving_game.connect(_on_leaving_game)
	SignalBus.time_slow_activated.connect(_on_time_slow_activated)
	SignalBus.time_slow_deactivated.connect(_on_time_slow_deactivated)
	SignalBus.player_first_movement.connect(_on_player_first_movement)
	time_slow_timer.timeout.connect(_on_time_slow_timer_timeout)

func _on_time_slow_activated():
	movement_speed = slow_movement_speed
	time_slow_timer.paused = false
	time_slow_timer.start()

func _on_time_slow_timer_timeout():
	SignalBus.time_slow_deactivated.emit()

func _on_time_slow_deactivated():
	movement_speed = normal_movement_speed

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
	if movement_started:
		movement_speed_multiplier += minf(movement_speed_multiplier_increase*delta, 1.0 - movement_speed_multiplier)
	set_origin(camera_origin - Vector2(movement_speed * delta * movement_speed_multiplier * DifficultyManager.difficulty, 0))
	
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
		for bullet in get_tree().get_nodes_in_group("bullets"):
			bullet.position -= Vector2(1920, 0)
		for projectile in get_tree().get_nodes_in_group("projectiles"):
			projectile.position -= Vector2(1920, 0)
		for power_up in get_tree().get_nodes_in_group("power-ups"):
			power_up.position -= Vector2(1920, 0)
		set_origin(camera_origin + Vector2(1920, 0))
		get_tree().root.add_child.call_deferred(next_scene)

func set_origin(new_origin: Vector2) -> void:
	var changed := camera_origin != new_origin
	var old_origin := camera_origin	
	camera_origin = new_origin
	camera_transform = Transform2D(0, camera_origin)
	get_viewport().set_canvas_transform(camera_transform)
	if changed:
		SignalBus.camera_moved.emit(-old_origin, -camera_origin)

func _on_leaving_game():
	if previous_scene != null: previous_scene.queue_free()
	current_scene.queue_free()
	next_scene.queue_free()
	set_origin(Vector2.ZERO)

func _on_player_first_movement():
	movement_started = true
