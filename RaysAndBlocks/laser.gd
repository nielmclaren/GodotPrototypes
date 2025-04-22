extends RayCast2D

class_name Laser

const DEFAULT_COLLISION_LAYER:int = 1
const REVERSE_CAST_COLLISION_LAYER:int = 2
const MAX_LASER_DEPTH:int = 5

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
	if laser_depth >= MAX_LASER_DEPTH:
		return

	# Indicate depth and external vs. internal
	($DepthLabel as Label).text = str(laser_depth) + ("i" if containing_block else "x")

	if containing_block:
		_process_internal_ray()

	else:
		_process_external_ray()

func _process_internal_ray() -> void:
	# The laser beam is inside a block. Reverse cast to find the exit intersection.
	# Can't collide with anything else until the laser exits the containing block.
	containing_block.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, true)

	reverse_cast.force_raycast_update()
	if reverse_cast.is_colliding():
		var cast_point:Vector2 = to_local(reverse_cast.get_collision_point())
		_update_art(cast_point)

		if not child_laser:
			child_laser = _instantiate_laser(laser_depth + 1)

		child_laser.clear_exceptions()
		child_laser.add_exception(containing_block as CollisionObject2D)

		# Child laser will be outside the block.
		child_laser.set_containing_block(null)

		_update_child_laser(cast_point)
	else:
		print("WARN: reverse raycast for internal laser didn't collide.")

		if child_laser:
			child_laser.queue_free()
			child_laser = null

		_update_art(Vector2.ZERO)

	containing_block.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, false)

func _process_external_ray() -> void:
	var cast_point:Vector2 = target_position

	force_raycast_update()
	if is_colliding():
		cast_point = to_local(get_collision_point())

		if not child_laser:
			child_laser = _instantiate_laser(laser_depth + 1)

		child_laser.clear_exceptions()
		child_laser.add_exception(get_collider() as CollisionObject2D)

		# Child laser will be inside the block.
		child_laser.set_containing_block(get_collider() as Block)

		_update_child_laser(cast_point)

	elif child_laser:
		child_laser.queue_free()
		child_laser = null

	_update_art(cast_point)

func set_containing_block(block:Block) -> void:
	containing_block = block

	if containing_block:
		reverse_cast = RayCast2D.new()
		reverse_cast.enabled = true
		reverse_cast.position = target_position
		reverse_cast.target_position = target_position.rotated(PI)

		# FIXME: Make collision layer implementation more robust.
		reverse_cast.set_collision_mask_value(DEFAULT_COLLISION_LAYER, false)
		reverse_cast.set_collision_mask_value(REVERSE_CAST_COLLISION_LAYER, true)

		add_child(reverse_cast)
	elif reverse_cast:
		reverse_cast.queue_free()

func _get_reverse_cast_collision() -> Dictionary:
	var result:Dictionary = {}

	# Can't collide with anything else until the laser exits the containing block.
	containing_block.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, true)

	reverse_cast.force_raycast_update()
	if reverse_cast.is_colliding():
					result = {
									"position": to_local(reverse_cast.get_collision_point()),
									"normal": reverse_cast.get_collision_normal(),
									"collider": reverse_cast.get_collider()
					}

	containing_block.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, false)
	return result

func _instantiate_laser(depth:int) -> Laser:
	var laser:Laser = laser_scene.instantiate()
	laser.laser_depth = depth
	add_child(laser)
	return laser

func _update_child_laser(start_position:Vector2) -> void:
	child_laser.position = start_position
	child_laser.rotation = rotation + PI/6

func _update_art(target_point:Vector2) -> void:
	var line:Line2D = $Line2D
	line.points[1] = target_point
	line.show()
