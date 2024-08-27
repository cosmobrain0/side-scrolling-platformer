extends Node2D

enum Facing {LEFT, RIGHT}

var levels: Array[Resource] = [preload("res://levels/level-0.tscn")]
@onready var player := $Player
var camera_origin := Vector2.ZERO

const dead_zone := Vector2(100, 100*9/16)
const centre_facing_right := Vector2(1920/2 - 500, 1080/2)
const centre_facing_left := Vector2(1920/2 + 500, 1080/2)
var centre := centre_facing_right
const movement_coefficient := 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level: TileMapLayer = levels[0].instantiate()
	level.position = Vector2(1920, 0)
	get_tree().root.add_child.call_deferred(level)
	SignalBus.player_facing_changed.connect(_on_player_facing_changed)

func _on_player_facing_changed(facing: Facing) -> void:
	if facing == Facing.LEFT: centre = centre_facing_left
	else: centre = centre_facing_right

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_coord: Vector2 = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * player.position
	var offset := screen_coord - centre
	if abs(offset.x) >= dead_zone.x:
		var distance: float = (abs(offset.x)-dead_zone.x) * movement_coefficient * delta
		if offset.x < 0.0:
			distance *= -1.0
		set_origin(camera_origin - Vector2(distance, 0))
	# TODO: add some y coordinate shenanigans maybe?

func set_origin(new_origin: Vector2) -> void:
	camera_origin = new_origin
	get_viewport().set_canvas_transform(Transform2D(0, camera_origin))
