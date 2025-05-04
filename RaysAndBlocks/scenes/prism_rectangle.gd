extends Interactible

class_name PrismRectangle

var prism_scene: PackedScene

func _ready() -> void:
	super._ready()

	prism_scene = load(scene_file_path) as PackedScene

	#drag_handle_radius = 0.4 * _get_radius(($CollisionPolygon2D as CollisionPolygon2D))
	drag_handle_radius = 50

	set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)
	set_collision_layer_value(Constants.LASER_COLLISION_LAYER, true)

func _mouse_entered() -> void:
	super._mouse_entered()

func _mouse_exited() -> void:
	super._mouse_exited()

func set_edit_state(state: int) -> void:
	match state:
		STATE_HOVER:
			modulate.a = 1.0
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)

		STATE_GHOST:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)

		STATE_GHOST_COLLISION:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 0.2
			modulate.b = 0.2
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)

		STATE_GHOST_REVERT:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 0.2
			modulate.b = 0.2
			is_snapped = false
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)

		_:
			modulate.a = 1.0
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)

func clone() -> PrismRectangle:
	var cloned: PrismRectangle = prism_scene.instantiate()
	cloned.rotation = rotation
	return cloned
