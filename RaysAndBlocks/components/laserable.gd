class_name Laserable
extends Node

@export var collision_object: CollisionObject2D
@export var collision_response: Constants.LaserHitResponse
@export var sensor: Sensor # Optional


func register_laser_hit() -> Constants.LaserHitResponse:
	if sensor:
		sensor.register_laser_hit()
	return collision_response


func _ready() -> void:
	collision_object.set_collision_layer_value(Constants.CollisionLayer.DEFAULT, false)
	collision_object.set_collision_layer_value(Constants.CollisionLayer.PHYSICAL, true)
	collision_object.set_collision_layer_value(Constants.CollisionLayer.LASERS, true)
	collision_object.set_collision_mask_value(Constants.CollisionLayer.DEFAULT, false)
	collision_object.set_collision_mask_value(Constants.CollisionLayer.PHYSICAL, true)
	collision_object.set_collision_mask_value(Constants.CollisionLayer.LASERS, false)
