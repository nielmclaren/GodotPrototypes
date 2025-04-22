extends RayCast2D

class_name Laser

var laser_scene:PackedScene
var child_laser:Laser
var laser_depth:int = 0

# If the previous laser beam intersected with a block, this one will be inside that block.
var containing_block:Block = null
var reverse_cast:RayCast2D = null

func _ready() -> void:
	laser_scene = load(scene_file_path) as PackedScene

	var line:Line2D = $Line2D
	line.hide()

func _physics_process(_delta:float) -> void:
	var cast_point:Vector2 = target_position
	if laser_depth >= 5:
		return

	($DepthLabel as Label).text = str(laser_depth)

	if containing_block:
		# The laser beam is inside a block. Reverse cast to find the exit intersection.
		# Can't collide with anything else until the laser exits the containing block.
		containing_block.set_collision_layer_value(2, true)
		reverse_cast.force_raycast_update()
		if reverse_cast.is_colliding():
			cast_point = to_local(reverse_cast.get_collision_point())

			if not child_laser:
				child_laser = laser_scene.instantiate()
				child_laser.laser_depth = laser_depth + 1
				add_child(child_laser)

			child_laser.clear_exceptions()
			child_laser.add_exception(containing_block as CollisionObject2D)
			child_laser.set_containing_block(null)

			child_laser.position = cast_point
			child_laser.rotation = rotation + PI/6

		containing_block.set_collision_layer_value(2, false)

	else:
		force_raycast_update()
		if is_colliding():
			cast_point = to_local(get_collision_point())

			if not child_laser:
				child_laser = laser_scene.instantiate()
				child_laser.laser_depth = laser_depth + 1
				add_child(child_laser)

			child_laser.clear_exceptions()
			child_laser.add_exception(get_collider() as CollisionObject2D)
			child_laser.set_containing_block(get_collider() as Block)

			child_laser.position = cast_point
			child_laser.rotation = rotation + PI/6

		elif child_laser:
			child_laser.queue_free()
			child_laser = null

	var line:Line2D = $Line2D
	line.points[1] = cast_point
	line.show()

func set_containing_block(block:Block) -> void:
	containing_block = block

	if containing_block:
		reverse_cast = RayCast2D.new()
		reverse_cast.enabled = true
		reverse_cast.position = target_position
		reverse_cast.target_position = target_position.rotated(PI)

		# FIXME: Make collision layer implementation more robust.
		reverse_cast.set_collision_mask_value(1, false)
		reverse_cast.set_collision_mask_value(2, true)

		add_child(reverse_cast)
	elif reverse_cast:
		reverse_cast.queue_free()
