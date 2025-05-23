class_name Laser
extends RayCast2D

@export var line: Line2D
@export var color: Constants.LaserColor

# The maximum number of reflections or refractions originating from a single ray.
const MAX_LASER_DEPTH: int = 100

var laserable_lookup: LaserableLookup
var laser_scene: PackedScene
var child_laser: Laser
var laser_depth: int = 0

# If the previous laser beam intersected with a prism, this one will be inside that prism.
var containing_body: CollisionObject2D = null

# A ray cast backwards to find the exit point of an internal ray.
var reverse_cast: RayCast2D = null


func _ready() -> void:
	laser_scene = load(scene_file_path) as PackedScene

	collide_with_areas = true
	set_collision_mask_value(Constants.CollisionLayer.DEFAULT, false)
	set_collision_mask_value(Constants.CollisionLayer.LASERS, true)

	_init_art()
	line.hide()
	var green_line: Line2D = $GreenDebugLine
	green_line.hide()
	var red_line: Line2D = $RedDebugLine
	red_line.hide()


func _physics_process(_delta: float) -> void:
	if laser_depth >= MAX_LASER_DEPTH:
		return

	var green_line: Line2D = $GreenDebugLine
	green_line.hide()

	if containing_body:
		_process_internal_ray()

	else:
		_process_external_ray()


func _process_internal_ray() -> void:
	# The laser beam is inside a body. Reverse cast to find the exit intersection.
	# Can't collide with anything else until the laser exits the containing body.
	containing_body.set_collision_layer_value(Constants.CollisionLayer.REVERSE_CAST, true)

	reverse_cast.force_raycast_update()

	if reverse_cast.is_colliding():
		var point: Vector2 = to_local(reverse_cast.get_collision_point())
		# Normal is backwards because of reverse cast so rotate it by PI.
		var normal: Vector2 = reverse_cast.get_collision_normal().rotated(PI)
		_update_art(point, normal)
		_process_internal_ray_collision(point, normal)

	else:
		print("WARN: reverse raycast for internal laser didn't collide.")
		_destroy_child_laser()
		_update_art(Vector2.ZERO, Vector2.ZERO)

	containing_body.set_collision_layer_value(Constants.CollisionLayer.REVERSE_CAST, false)


func _process_internal_ray_collision(collision_point: Vector2, normal: Vector2) -> void:
	var in_material: Constants.LaserMaterial = laserable_lookup.get_laser_material(containing_body)
	var out_material: Constants.LaserMaterial = Constants.LaserMaterial.VACUUM
	var direction: Vector2 = Vector2.from_angle(global_rotation)
	var in_angle: float = normal.angle_to(direction)
	var wavelength: float = LightPhysics.get_wavelength(color)

	_ensure_child_laser()

	# Prevent child laser from colliding with the body where it originates.
	child_laser.add_exception(containing_body)

	if LightPhysics.is_internal_reflection(in_angle, wavelength, in_material, out_material):
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
		child_laser.global_rotation = _get_refraction_global_rotation(
			normal, in_material, out_material
		)


func _process_external_ray() -> void:
	force_raycast_update()

	if is_colliding():
		var cast_point: Vector2 = to_local(get_collision_point())
		var normal: Vector2 = get_collision_normal()
		_update_art(cast_point, normal)
		_process_external_ray_collision(cast_point, normal)

	else:
		_update_art(target_position, Vector2.ZERO)
		_destroy_child_laser()


func _process_external_ray_collision(point: Vector2, normal: Vector2) -> void:
	var collider: Node2D = get_collider()
	var collision_response: Constants.LaserHitResponse = laserable_lookup.register_laser_hit(
		collider
	)

	if collision_response == Constants.LaserHitResponse.REFRACT:
		var collision_object: CollisionObject2D = collider
		var in_material: Constants.LaserMaterial = Constants.LaserMaterial.VACUUM
		var out_material: Constants.LaserMaterial = laserable_lookup.get_laser_material(
			collision_object
		)

		_ensure_child_laser()

		# Prevent child laser from colliding with the body where it originates.
		child_laser.add_exception(collision_object)

		# Child laser will be inside the body.
		child_laser._set_containing_body(collision_object)

		child_laser.position = point
		child_laser.global_rotation = _get_refraction_global_rotation(
			normal, in_material, out_material
		)

	elif collision_response == Constants.LaserHitResponse.REFLECT:
		var collision_object: CollisionObject2D = collider

		_ensure_child_laser()

		# Prevent child laser from colliding with the body where it originates.
		child_laser.add_exception(collision_object)

		# Child laser will be outside the body.
		child_laser._set_containing_body(null)

		child_laser.position = point
		child_laser.global_rotation = _get_reflection_global_rotation(normal)

	else:
		# Collided with a wall or viewport bounds. Dead end.
		_destroy_child_laser()


func _set_containing_body(body: CollisionObject2D) -> void:
	containing_body = body

	if containing_body:
		# Since there is a containing body, a reverse cast will be needed to calculate the exit point.
		if !reverse_cast:
			reverse_cast = RayCast2D.new()
			add_child(reverse_cast)

			reverse_cast.collide_with_areas = true

			reverse_cast.set_collision_mask_value(Constants.CollisionLayer.DEFAULT, false)
			reverse_cast.set_collision_mask_value(Constants.CollisionLayer.REVERSE_CAST, true)

		reverse_cast.position = target_position
		reverse_cast.target_position = target_position.rotated(PI)

	elif reverse_cast:
		reverse_cast.queue_free()


func _ensure_child_laser() -> void:
	if not child_laser:
		child_laser = _instantiate_laser(laser_depth + 1)

	# Reset
	child_laser.clear_exceptions()


func _instantiate_laser(depth: int) -> Laser:
	var laser: Laser = laser_scene.instantiate()
	laser.color = color
	laser.laser_depth = depth
	laser.laserable_lookup = laserable_lookup
	add_child(laser)
	return laser


func _destroy_child_laser() -> void:
	if child_laser:
		child_laser.queue_free()
		child_laser = null


func _get_refraction_global_rotation(
	normal: Vector2, in_material: Constants.LaserMaterial, out_material: Constants.LaserMaterial
) -> float:
	var direction: Vector2 = Vector2.from_angle(global_rotation)
	var reverse_normal: Vector2 = normal.rotated(PI)
	var in_angle: float = reverse_normal.angle_to(direction)
	var wavelength: float = LightPhysics.get_wavelength(color)
	var out_angle: float = LightPhysics.get_angle_of_refraction(
		in_angle, wavelength, in_material, out_material
	)
	return reverse_normal.rotated(out_angle).angle()


func _get_reflection_global_rotation(normal: Vector2) -> float:
	var direction: Vector2 = Vector2.from_angle(global_rotation).rotated(PI)
	var reverse_normal: Vector2 = normal.rotated(PI)
	return direction.rotated(2 * direction.angle_to(reverse_normal)).angle()


func _init_art() -> void:
	line.modulate.r = 255 if color == Constants.LaserColor.RED else 0
	line.modulate.g = 255 if color == Constants.LaserColor.GREEN else 0
	line.modulate.b = 255 if color == Constants.LaserColor.BLUE else 0


func _update_art(target_point: Vector2, normal: Vector2) -> void:
	line.points[1] = target_point
	line.show()

	var green_line: Line2D = $GreenDebugLine
	if Constants.IS_DEBUG and normal.length() > 0:
		green_line.points[0] = target_point
		green_line.points[1] = target_point + normal.rotated(-global_rotation) * 20
		green_line.show()
	else:
		green_line.hide()

	var red_line: Line2D = $RedDebugLine
	if Constants.IS_DEBUG:
		red_line.show()
	else:
		red_line.hide()
