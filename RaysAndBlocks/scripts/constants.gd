extends Node

# Objects that can be hit by other objects, e.g., mirrors, prisms, and walls.
const DEFAULT_COLLISION_LAYER: int = 1

# Objects that can be hit by lasers, e.g., mirrors, walls, and smoke.
const LASER_COLLISION_LAYER: int = 2

# Collision layer for finding the exit point of an internal ray. Leave empty.
# Bodies are added to it as needed.
const LASER_REVERSE_CAST_COLLISION_LAYER: int = 3

const START_LEVEL_NUM: int = 5