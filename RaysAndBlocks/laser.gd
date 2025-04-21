extends RayCast2D

class_name Laser

var laser_scene:PackedScene
var child_laser:Laser

func _ready() -> void:
	laser_scene = load(scene_file_path) as PackedScene

	var line:Line2D = $Line2D
	line.hide()

func _physics_process(delta:float) -> void:
	var cast_point:Vector2 = target_position
	force_raycast_update()

	if is_colliding():
		cast_point = to_local(get_collision_point())
		
		if not child_laser:
			child_laser = laser_scene.instantiate()
			child_laser.add_exception(get_collider() as CollisionObject2D)
			add_child(child_laser)

		child_laser.position = cast_point
		child_laser.rotation = rotation + PI/6

	elif child_laser:
		child_laser.queue_free()
		child_laser = null

	var line:Line2D = $Line2D
	line.points[1] = cast_point
	line.show()
