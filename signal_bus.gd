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
