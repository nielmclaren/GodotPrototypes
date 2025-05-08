extends Node

class_name DragAndDrop

var scene: Node2D = null
var drag_node: Interactible = null
var drag_ghost: Interactible = null
var click_offset: Vector2 = Vector2.ZERO
var interactibles: Array[Mirror] = []

var is_invalidated: bool = false

# Adds functionality to any children that implement the `drag_start` signal.
func init(s: Node2D) -> void:
	scene = s
	_register_interactibles(scene)
	invalidate()

func _register_interactibles(parent_scene: Node2D) -> void:
	var children: Array[Node] = parent_scene.get_children()
	for child: Node in children:
		if child is Interactible:
			var interactible: Interactible = child
			interactible.drag_and_drop = self
			interactible.drag_start.connect(_node_clicked)
			interactibles.push_front(interactible)

func _node_clicked(node: Interactible) -> void:
	click_offset = scene.get_global_mouse_position() - node.global_position
	drag_node = node
	drag_node.set_is_drag_original(true)

	drag_ghost = node.clone()
	scene.add_child(drag_ghost)

	drag_ghost.set_is_drag_ghost(true)
	drag_ghost.global_position = scene.get_global_mouse_position() - click_offset
	drag_ghost.add_collision_exception_with(node)

func physics_process(_delta: float) -> void:
	if drag_ghost:
		drag_ghost.global_position = scene.get_global_mouse_position() - click_offset
		invalidate()

	if is_invalidated:
		validate()

func invalidate() -> void:
	is_invalidated = true

func validate() -> void:
	is_invalidated = false

	for interactible: Interactible in interactibles:
		interactible.validate()

	if drag_ghost:
		drag_ghost.validate()

func unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()

func _mouse_released() -> void:
	if drag_node:
		drag_node.set_is_drag_original(false)

	if drag_ghost:
		drag_ghost.global_position = scene.get_global_mouse_position() - click_offset

		if drag_ghost.is_colliding():
			_revert_drag()
			drag_ghost.set_is_drag_ghost(false)
			drag_ghost.set_is_reverting(true)

		else:
			drag_node.global_position = drag_ghost.global_position
			drag_node = null

			drag_ghost.queue_free()
			drag_ghost = null

func _revert_drag() -> void:
	drag_ghost.set_is_reverting(true)

	var tween: Tween = drag_ghost.create_tween()
	tween.tween_property(drag_ghost, "position", drag_node.position, 0.3)
	tween.parallel().tween_property(drag_ghost, "modulate:a", 0.2, 0.3)

	# Use currying to ensure the correct ghost is freed. This solves an issue where the
	# new ghost is freed if a node is dragged before the previous tween is finished.
	var remove_ghost: Callable = func(ghost: Interactible) -> Callable:
		return func() -> void:
			ghost.queue_free()
	var handler: Callable = remove_ghost.call(drag_ghost)
	tween.finished.connect(handler)

	# `queue_free()` will happen after the revert animation but this
	# reference needs to be set to null immediately.
	drag_ghost = null

func _revert_drag_tween_finished() -> void:
	drag_ghost.queue_free()
	drag_ghost = null
