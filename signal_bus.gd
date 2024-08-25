extends Node

enum Facing {LEFT, RIGHT}

signal player_facing_changed(facing: Facing)
signal goomba_collider_hit(player: Node2D)
