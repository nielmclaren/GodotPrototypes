extends RayCast2D

class_name Laser

const DEFAULT_COLLISION_LAYER:int = 1
const REVERSE_CAST_COLLISION_LAYER:int = 2
const MAX_LASER_DEPTH:int = 5
const REFRACTIVE_INDEX_GLASS:float = 1.52

var laser_scene:PackedScene
var child_laser:Laser
var laser_depth:int = 0

# If the previous laser beam intersected with a body, this one will be inside that body.
var containing_body:CollisionObject2D = null
var reverse_cast:RayCast2D = null

func _ready() -> void:
	laser_scene = load(scene_file_path) as PackedScene

	var line:Line2D = $Line2D
	line.hide()

func _physics_process(_delta:float) -> void:
	if laser_depth >= MAX_LASER_DEPTH:
		return

	# Indicate depth and external vs. internal
	($DepthLabel as Label).text = str(laser_depth) + ("i" if containing_body else "x")

	var green_line:Line2D = $GreenLine
	green_line.hide()

	if containing_body:
		_process_internal_ray()

	else:
		_process_external_ray()

func _process_internal_ray() -> void:
	# The laser beam is inside a body. Reverse cast to find the exit intersection.
	# Can't collide with anything else until the laser exits the containing body.
	containing_body.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, true)

	reverse_cast.force_raycast_update()
	if reverse_cast.is_colliding():
		var cast_point:Vector2 = to_local(reverse_cast.get_collision_point())
		_update_art(cast_point, reverse_cast.get_collision_normal())

		var normal:Vector2 = reverse_cast.get_collision_normal().rotated(PI)
		var angle_of_refraction:float = _get_angle_of_refraction(normal, true)

		if PI/2 - angle_of_refraction < deg_to_rad(3):
			if child_laser:
				child_laser.queue_free()
				child_laser = null
		else:
			if not child_laser:
				child_laser = _instantiate_laser(laser_depth + 1)

			child_laser.clear_exceptions()
			child_laser.add_exception(containing_body)

			# Child laser will be outside the body.
			child_laser.set_containing_body(null)

			child_laser.position = cast_point
			child_laser.global_rotation = _get_child_laser_global_rotation(normal, true)
	else:
		print("WARN: reverse raycast for internal laser didn't collide.")

		if child_laser:
			child_laser.queue_free()
			child_laser = null

		_update_art(Vector2.ZERO, Vector2.ZERO)

	containing_body.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, false)

func _process_external_ray() -> void:
	var cast_point:Vector2 = target_position
	var normal:Vector2 = Vector2.ZERO

	force_raycast_update()
	if is_colliding():
		var collider:CollisionObject2D = get_collider()
		cast_point = to_local(get_collision_point())
		normal = get_collision_normal()

		if not child_laser:
			child_laser = _instantiate_laser(laser_depth + 1)

		child_laser.clear_exceptions()
		child_laser.add_exception(collider)

		# Child laser will be inside the body.
		child_laser.set_containing_body(collider)

		child_laser.position = cast_point
		child_laser.global_rotation = _get_child_laser_global_rotation(get_collision_normal(), false)

	elif child_laser:
		child_laser.queue_free()
		child_laser = null

	_update_art(cast_point, normal)

func set_containing_body(body:CollisionObject2D) -> void:
	containing_body = body

	if containing_body:
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

	# Can't collide with anything else until the laser exits the containing body.
	containing_body.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, true)

	reverse_cast.force_raycast_update()
	if reverse_cast.is_colliding():
					result = {
									"position": to_local(reverse_cast.get_collision_point()),
									"normal": reverse_cast.get_collision_normal(),
									"collider": reverse_cast.get_collider()
					}

	containing_body.set_collision_layer_value(REVERSE_CAST_COLLISION_LAYER, false)
	return result

func _instantiate_laser(depth:int) -> Laser:
	var laser:Laser = laser_scene.instantiate()
	laser.laser_depth = depth
	add_child(laser)
	return laser

func _get_angle_of_refraction(normal:Vector2, is_internal:bool) -> float:
	var direction:Vector2 = Vector2.from_angle(global_rotation)
	var reverse_normal:Vector2 = normal.rotated(PI)
	var in_angle:float = reverse_normal.angle_to(direction)

	if is_internal:
		return asin( sin(in_angle) * REFRACTIVE_INDEX_GLASS  )

	return asin( sin(in_angle) / REFRACTIVE_INDEX_GLASS )

func _get_child_laser_global_rotation(normal:Vector2, is_internal:bool) -> float:
	var reverse_normal:Vector2 = normal.rotated(PI)
	var out_angle:float = _get_angle_of_refraction(normal, is_internal)
	return reverse_normal.rotated(out_angle).angle()

func _update_art(target_point:Vector2, normal:Vector2) -> void:
	var line:Line2D = $Line2D
	line.points[1] = target_point
	line.show()

	var green_line:Line2D = $GreenLine
	if normal.length() > 0:
		green_line.points[0] = target_point
		green_line.points[1] = target_point + normal.rotated(-global_rotation) * 20
		green_line.show()
	else:
		green_line.hide()
