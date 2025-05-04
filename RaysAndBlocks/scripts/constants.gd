extends Node

const DEFAULT_COLLISION_LAYER: int = 1

const LASER_COLLISION_LAYER: int = 2

# Collision layer for finding the exit point of an internal ray.
const LASER_REVERSE_CAST_COLLISION_LAYER: int = 3

const CELL_SIZE: Vector2 = Vector2(32, 32)

const START_LEVEL_NUM: int = 5