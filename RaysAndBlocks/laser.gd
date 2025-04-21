extends RayCast2D

class_name Laser

func _physics_process(_delta:float) -> void:
	var cast_point:Vector2 = target_position
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
	var line:Line2D = $Line2D
	line.points[1] = cast_point
