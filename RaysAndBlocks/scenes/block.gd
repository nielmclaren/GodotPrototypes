extends Interactible

class_name Block

var block_scene: PackedScene

func _ready() -> void:
	super._ready()

	block_scene = load(scene_file_path) as PackedScene

	drag_handle_radius = 0.4 * _get_radius(($CollisionShape2D as CollisionShape2D).shape)

	set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)
	set_collision_layer_value(Constants.LASER_COLLISION_LAYER, true)

	($DefaultSprite as Sprite2D).show()
	($HoverSprite as Sprite2D).hide()

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
			($DefaultSprite as Sprite2D).hide()
			($HoverSprite as Sprite2D).show()

		STATE_GHOST:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)
			($DefaultSprite as Sprite2D).hide()
			($HoverSprite as Sprite2D).show()

		STATE_GHOST_COLLISION:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 0.2
			modulate.b = 0.2
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)
			($DefaultSprite as Sprite2D).hide()
			($HoverSprite as Sprite2D).show()

		STATE_GHOST_REVERT:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 0.2
			modulate.b = 0.2
			is_snapped = false
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, false)
			($DefaultSprite as Sprite2D).hide()
			($HoverSprite as Sprite2D).show()

		_:
			modulate.a = 1.0
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0
			is_snapped = true
			set_collision_layer_value(Constants.DEFAULT_COLLISION_LAYER, true)
			($DefaultSprite as Sprite2D).show()
			($HoverSprite as Sprite2D).hide()

func clone() -> Block:
	var block: Block = block_scene.instantiate()
	block.rotation = rotation
	return block
