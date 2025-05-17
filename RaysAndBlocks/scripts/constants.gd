extends Node

enum CollisionLayer {
	DEFAULT = 1, # For mouse events.
	PHYSICAL = 2, # For collisions between walls, mirrors, and prisms.
	LASERS = 4, # For lasers to hit walls, mirrors, and prisms.
	REVERSE_CAST = 5 # Used as needed for lasers. Leave empty.
	}

enum LaserHitResponse { ABSORB, REFLECT, REFRACT }

const IS_DEBUG: bool = false

# The numbers in this array match the file names.
const ENABLED_LEVELS: Array[int] = [
	#0,  # The Basics (mirror)
	#1, # The Pit (mirror, pit)
	#2,  # Thin gap (mirror, foreshadows multi-bounce)
	#3, # Skull (mirror, multi-bounce)
	#4,  # Two-Sided (mirror, two-sided)
	#5,  # Spiral (mirror and rect)
	#6,  # Intro to Steam (mirror and rect)
	7, # Three Hard Turns (rect prism hard turn)
	8, # Do-Si-Do (rect prism do-si-do)
	9 # Twice Two Lasers (rect prism hard turn + do-si-do)
]
