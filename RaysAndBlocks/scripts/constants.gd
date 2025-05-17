extends Node

enum CollisionLayer { DEFAULT = 1, PHYSICAL = 2, LASERS = 4, REVERSE_CAST = 5 }  # For mouse events.  # For collisions between walls, mirrors, and prisms.  # For lasers to hit walls, mirrors, and prisms.  # Used as needed for lasers. Leave empty.

enum LaserHitResponse { ABSORB, REFLECT, REFRACT }

const IS_DEBUG: bool = false
