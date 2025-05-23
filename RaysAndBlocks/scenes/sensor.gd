class_name Sensor
extends Node2D

signal activated

@export var receiver: StaticBody2D
@export var base: StaticBody2D
@export var sprite: AnimatedSprite2D

# The amount of time the sensor must be hit by a laser to become active.
const ACTIVATION_DELAY_MS: float = 1500

var is_hit: bool = false
var is_hit_prev: bool = false
var hit_time: float
var is_active: bool
var is_activated_emitted: bool = false


func _ready() -> void:
	base.set_collision_layer_value(Constants.CollisionLayer.DEFAULT, true)
	base.set_collision_layer_value(Constants.CollisionLayer.PHYSICAL, true)
	base.set_collision_layer_value(Constants.CollisionLayer.LASERS, true)

	receiver.set_collision_layer_value(Constants.CollisionLayer.DEFAULT, true)
	receiver.set_collision_layer_value(Constants.CollisionLayer.PHYSICAL, true)
	receiver.set_collision_layer_value(Constants.CollisionLayer.LASERS, true)

	sprite.set_frame(0)


func _physics_process(_delta: float) -> void:
	if !GlobalState.is_game_input_enabled:
		return

	if is_hit and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var now: float = Time.get_ticks_msec()
		if !is_hit_prev:
			hit_time = now

			sprite.set_frame(1)
			sprite.play()
		elif !is_activated_emitted and now - ACTIVATION_DELAY_MS > hit_time:
			is_active = true
			activated.emit()
			is_activated_emitted = true

		is_hit = false
		is_hit_prev = true

	else:
		sprite.set_frame(0)

		is_active = false
		is_activated_emitted = false
		is_hit = false
		is_hit_prev = false


# TODO: There's no guarantee that Laser._physics_process() will be called
#       exactly once for each call to `Sensor._process()`.
func register_laser_hit() -> void:
	is_hit = true
