extends StaticBody2D

func _ready() -> void:
	set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)
	set_collision_layer_value(Constants.LASER_COLLISION_LAYER, true)
