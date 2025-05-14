extends Node

enum CollisionLayer { DEFAULT = 1, MOUNTS = 2, FIXTURES = 3, LASERS = 4, REVERSE_CAST = 5 }

enum LaserCollisionResponse { ABSORB, REFLECT, REFRACT }

const IS_DEBUG: bool = false

# The numbers in this array match the file names.
const ENABLED_LEVELS: Array[int] = [
	0,  # The Basics (mirror)
	#1, # The Pit (mirror, pit)
	2,  # Thin gap (mirror, foreshadows multi-bounce)
	#3, # Skull (mirror, multi-bounce)
	4,  # Two-Sided (mirror, two-sided)
	5,  # Spiral (mirror and rect)
	6  # Intro to steam (mirror and rect)
]
