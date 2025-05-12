extends StaticBody2D

class_name Sensor

signal activated

# The amount of time the sensor must be hit by a laser to become active.
const ACTIVATION_DELAY_MS: float = 1000

var is_hit: bool = false
var is_hit_prev: bool = false
var hit_time: float
var is_active: bool
var is_activated_emitted: bool = false

func _ready() -> void:
	set_collision_layer_value(Constants.CollisionLayer.DEFAULT, true)
	set_collision_layer_value(Constants.CollisionLayer.MOUNTS, true)
	set_collision_layer_value(Constants.CollisionLayer.FIXTURES, true)
	set_collision_layer_value(Constants.CollisionLayer.LASERS, true)

func _process(_delta: float) -> void:
	if is_hit:
		var now: float = Time.get_ticks_msec()
		if !is_hit_prev:
			hit_time = now
		elif !is_activated_emitted and now - ACTIVATION_DELAY_MS > hit_time:
			is_active = true
			activated.emit()
			is_activated_emitted = true

		($SpriteActive as Sprite2D).show()
		($SpriteInactive as Sprite2D).hide()

		is_hit = false
		is_hit_prev = true

	else:
		($SpriteActive as Sprite2D).hide()
		($SpriteInactive as Sprite2D).show()

		is_active = false
		is_activated_emitted = false
		is_hit_prev = false


# TODO: There's no guarantee that Laser._physics_process() will be called
#       exactly once for each call to `Sensor._process()`.
func register_laser_collision(_laser: Laser) -> void:
	is_hit = true
