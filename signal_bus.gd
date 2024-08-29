extends Node

enum Facing {LEFT, RIGHT}

signal player_facing_changed(facing: Facing)
signal player_jumped(facing: Facing)
signal player_landed(facing: Facing)
signal goomba_collider_hit(player: Node2D)
signal goomba_bounced_on(player: Node2D)
signal bullet_spawned(bullet: Node2D, facing: Facing)
signal goomba_shot(bullet: Node2D, goomba: Area2D)
signal game_restart()
signal spike_hit_player(spike: Node2D)
signal player_health_changed(old_health: float, new_health: float)
signal camera_moved(old_position: Vector2, new_position: Vector2)
signal player_invincible()
signal player_not_invincible()
signal player_lost()
signal score_changed(old_score: float, new_score: float, position: Vector2)
signal leaving_game()
