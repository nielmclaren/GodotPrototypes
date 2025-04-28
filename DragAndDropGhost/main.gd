extends Node2D

var drag_block: Block = null
var drag_ghost: Block = null

func _ready() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is Block:
			var block: Block = child
			block.clicked.connect(_block_clicked)

func _physics_process(_delta: float) -> void:
	if drag_ghost:
		var collision: KinematicCollision2D = drag_ghost.move_and_collide(get_global_mouse_position() - drag_ghost.global_position, true)
		drag_ghost.global_position = get_global_mouse_position()
		if collision:
			drag_ghost.modulate.r = 1.0
			drag_ghost.modulate.g = 0.2
			drag_ghost.modulate.b = 0.2
		else:
			drag_ghost.modulate.r = 1.0
			drag_ghost.modulate.g = 1.0
			drag_ghost.modulate.b = 1.0

func _block_clicked(block: Block) -> void:
	drag_block = block
	drag_ghost = block.clone()
	drag_ghost.global_position = get_global_mouse_position()
	drag_ghost.modulate.a = 0.4
	drag_ghost.add_collision_exception_with(block)
	add_child(drag_ghost)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()

func _mouse_released() -> void:
	if drag_ghost:
		var collision: KinematicCollision2D = drag_ghost.move_and_collide(get_global_mouse_position() - drag_ghost.global_position, true)
		drag_ghost.global_position = get_global_mouse_position()

		if collision:
			var tween: Tween = drag_ghost.create_tween()
			tween.tween_property(drag_ghost, "position", drag_block.position, 0.3)
			tween.parallel().tween_property(drag_ghost, "modulate:a", 0, 0.3)
			tween.finished.connect(_revert_drag_tween_finished)

		else:
			drag_block.global_position = drag_ghost.global_position
			drag_ghost.queue_free()
			drag_ghost = null

func _revert_drag_tween_finished() -> void:
	drag_ghost.queue_free()
	drag_ghost = null
