extends Node2D

enum Facing {LEFT, RIGHT}

var levels: Array[Resource] = [preload("res://levels/level-0.tscn")]
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
	next_scene = levels[0].instantiate()
	next_scene.position = Vector2(1920, 0)
	get_tree().root.add_child.call_deferred(next_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_origin(camera_origin - Vector2(movement_speed * delta, 0))
	var screen_player_pos: Vector2 = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * player.position
	if screen_player_pos.x <= left_bound_for_player:
		get_tree().reload_current_scene()
		return
	if camera_origin_x_at_last_level_spawn + 1700 <= -camera_origin.x:
		camera_origin_x_at_last_level_spawn += 1920
		if previous_scene != null:
			previous_scene.queue_free()
		previous_scene = current_scene
		current_scene = next_scene
		next_scene = levels[0].instantiate()
		next_scene.position = Vector2(camera_origin_x_at_last_level_spawn + 1920, 0)
		get_tree().root.add_child.call_deferred(next_scene)

func set_origin(new_origin: Vector2) -> void:
	camera_origin = new_origin
	get_viewport().set_canvas_transform(Transform2D(0, camera_origin))
