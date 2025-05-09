extends StaticBody2D

func _ready() -> void:
	set_collision_layer_value(Constants.CollisionLayer.DEFAULT, true)
	set_collision_layer_value(Constants.CollisionLayer.MOUNTS, true)
	set_collision_layer_value(Constants.CollisionLayer.FIXTURES, true)
	set_collision_layer_value(Constants.CollisionLayer.LASERS, true)
