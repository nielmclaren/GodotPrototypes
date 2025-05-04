extends RayCast2D

class_name Laser

# The maximum number of reflections or refractions originating from a single ray.
const MAX_LASER_DEPTH:int = 10
const REFRACTIVE_INDEX_GLASS:float = 1.52

# A refraction is considered an internal reflection instead if it's within ±(error) of ±π.
const MAX_CRITICAL_ANGLE_DETECTION_ERROR:float = 3.0

var laser_scene:PackedScene
var child_laser:Laser
var laser_depth:int = 0

# If the previous laser beam intersected with a prism, this one will be inside that prism.
var containing_body:CollisionObject2D = null

# A ray cast backwards to find the exit point of an internal ray.
var reverse_cast:RayCast2D = null

func _ready() -> void:
	laser_scene = load(scene_file_path) as PackedScene

	set_collision_mask_value(Constants.DEFAULT_COLLISION_LAYER, false)
	set_collision_mask_value(Constants.LASER_COLLISION_LAYER, true)

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
	containing_body.set_collision_layer_value(Constants.LASER_REVERSE_CAST_COLLISION_LAYER, true)

	reverse_cast.force_raycast_update()

	if reverse_cast.is_colliding():
		var point:Vector2 = to_local(reverse_cast.get_collision_point())
		var normal:Vector2 = reverse_cast.get_collision_normal().rotated(PI)

		_update_art(point, reverse_cast.get_collision_normal())
		_process_internal_ray_collision(point, normal)

	else:
		print("WARN: reverse raycast for internal laser didn't collide.")

		if child_laser:
			child_laser.queue_free()
			child_laser = null

		_update_art(Vector2.ZERO, Vector2.ZERO)

	containing_body.set_collision_layer_value(Constants.LASER_REVERSE_CAST_COLLISION_LAYER, false)

func _process_internal_ray_collision(collision_point:Vector2, normal:Vector2) -> void:
	var angle_of_refraction:float = _get_angle_of_refraction(normal, true)

	if not child_laser:
		child_laser = _instantiate_laser(laser_depth + 1)

	# Prevent child laser from colliding with the body where it originates.
	child_laser.clear_exceptions()
	child_laser.add_exception(containing_body)

	if PI/2 - abs(angle_of_refraction) < deg_to_rad(MAX_CRITICAL_ANGLE_DETECTION_ERROR):
		# Refraction angle is greater than the critical angle. Process an internal reflection instead.

		# Child laser will be inside the body.
		child_laser._set_containing_body(containing_body)

		child_laser.position = collision_point
		child_laser.global_rotation = _get_reflection_global_rotation(normal)

	else:
		# Refraction.

		# Child laser will be outside the body.
		child_laser._set_containing_body(null)

		child_laser.position = collision_point
		child_laser.global_rotation = _get_refraction_global_rotation(normal, true)

func _process_external_ray() -> void:
	force_raycast_update()

	if is_colliding():
		var cast_point:Vector2 = to_local(get_collision_point())
		var normal:Vector2 = get_collision_normal()

		_update_art(cast_point, normal)
		_process_external_ray_collision(cast_point, normal)

	else:
		_update_art(target_position, Vector2.ZERO)

		if child_laser:
			child_laser.queue_free()
			child_laser = null

func _process_external_ray_collision(point:Vector2, normal:Vector2) -> void:
	var collider:CollisionObject2D = get_collider()
	if collider is Block or collider is PrismRectangle or collider is PrismTriangle:
		# Refraction.

		if not child_laser:
			child_laser = _instantiate_laser(laser_depth + 1)

		# Prevent child laser from colliding with the body where it originates.
		child_laser.clear_exceptions()
		child_laser.add_exception(collider)

		# Child laser will be inside the body.
		child_laser._set_containing_body(collider)

		child_laser.position = point
		child_laser.global_rotation = _get_refraction_global_rotation(normal, false)

	elif collider is Mirror:
		# Reflection.

		if not child_laser:
			child_laser = _instantiate_laser(laser_depth + 1)

		# Prevent child laser from colliding with the body where it originates.
		child_laser.clear_exceptions()
		child_laser.add_exception(collider)

		# Child laser will be outside the body.
		child_laser._set_containing_body(null)

		child_laser.position = point
		child_laser.global_rotation = _get_reflection_global_rotation(normal)

	elif collider is Sensor:
		var sensor:Sensor = collider
		sensor.register_laser_collision(self)

		if child_laser:
			child_laser.queue_free()
			child_laser = null

	else:
		# Collided with a wall or viewport bounds. Dead end.
		if child_laser:
			child_laser.queue_free()
			child_laser = null

func _set_containing_body(body:CollisionObject2D) -> void:
	containing_body = body

	if containing_body:
		reverse_cast = RayCast2D.new()
		reverse_cast.enabled = true
		reverse_cast.position = target_position
		reverse_cast.target_position = target_position.rotated(PI)

		# FIXME: Make collision layer implementation more robust.
		reverse_cast.set_collision_mask_value(Constants.DEFAULT_COLLISION_LAYER, false)
		reverse_cast.set_collision_mask_value(Constants.LASER_REVERSE_CAST_COLLISION_LAYER, true)

		add_child(reverse_cast)
	elif reverse_cast:
		reverse_cast.queue_free()

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

func _get_refraction_global_rotation(normal:Vector2, is_internal:bool) -> float:
	var reverse_normal:Vector2 = normal.rotated(PI)
	var out_angle:float = _get_angle_of_refraction(normal, is_internal)
	return reverse_normal.rotated(out_angle).angle()

func _get_reflection_global_rotation(normal:Vector2) -> float:
	var direction:Vector2 = Vector2.from_angle(global_rotation).rotated(PI)
	var reverse_normal:Vector2 = normal.rotated(PI)
	return direction.rotated(2*direction.angle_to(reverse_normal)).angle()

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
