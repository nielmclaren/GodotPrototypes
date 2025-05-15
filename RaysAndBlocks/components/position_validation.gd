class_name PositionValidation
extends Node

@export var body: Node2D
@export var hit_area: Area2D


func _physics_process(_delta: float) -> void:
	if is_colliding():
		hit_area.set_collision_layer_value(Constants.CollisionLayer.LASERS, false)
		_modulate(1.0, 0.2, 0.2, 0.7)

	else:
		hit_area.set_collision_layer_value(Constants.CollisionLayer.LASERS, true)
		_modulate(1.0, 1.0, 1.0, 1.0)


func is_colliding() -> bool:
	return hit_area.has_overlapping_areas() or hit_area.has_overlapping_bodies()


func _modulate(r: float, g: float, b: float, a: float) -> void:
	body.modulate.r = r
	body.modulate.g = g
	body.modulate.b = b
	body.modulate.a = a
