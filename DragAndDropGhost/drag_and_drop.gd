extends Node

class_name DragAndDrop

const STATE_DEFAULT: int = 0
const STATE_GHOST: int = 1
const STATE_COLLISION: int = 2

var scene: Node2D = null
var drag_node: CollisionObject2D = null
var drag_ghost: CollisionObject2D = null

# Adds functionality to any children that implement the `drag_start` signal and
# the `clone()` method.
func init(s: Node2D) -> void:
	scene = s
	_register_draggable_children(scene)

func _register_draggable_children(scene: Node2D) -> void:
	var children: Array[Node] = scene.get_children()
	for child: Node in children:
		if child.has_signal("drag_start") and child.has_method("clone"):
			child.drag_start.connect(_node_clicked)

func _node_clicked(node: CollisionObject2D) -> void:
	drag_node = node
	drag_ghost = node.clone()
	drag_ghost.global_position = scene.get_global_mouse_position()
	if drag_ghost.has_method("set_drag_and_drop_state"):
		drag_ghost.set_drag_and_drop_state(STATE_GHOST)
	drag_ghost.add_collision_exception_with(node)
	scene.add_child(drag_ghost)

func physics_process(_delta: float) -> void:
	if drag_ghost:
		var collision: KinematicCollision2D = drag_ghost.move_and_collide(scene.get_global_mouse_position() - drag_ghost.global_position, true)
		drag_ghost.global_position = scene.get_global_mouse_position()

		if drag_ghost.has_method("set_drag_and_drop_state"):
			if collision:
				drag_ghost.set_drag_and_drop_state(STATE_COLLISION)
			else:
				drag_ghost.set_drag_and_drop_state(STATE_GHOST)

func unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()

func _mouse_released() -> void:
	if drag_ghost:
		var collision: KinematicCollision2D = drag_ghost.move_and_collide(scene.get_global_mouse_position() - drag_ghost.global_position, true)
		drag_ghost.global_position = scene.get_global_mouse_position()

		if collision:
			var tween: Tween = drag_ghost.create_tween()
			tween.tween_property(drag_ghost, "position", drag_node.position, 0.3)
			tween.parallel().tween_property(drag_ghost, "modulate:r", 0, 0.3)

			# Use currying to ensure the correct ghost is freed. This solves an issue where the
			# new ghost is freed if a node is dragged before the previous tween is finished.
			var remove_ghost: Callable = func(ghost: CollisionObject2D) -> Callable:
				return func() -> void:
					ghost.queue_free()
			tween.finished.connect(remove_ghost.call(drag_ghost))

			# `queue_free()` will happen after the revert animation but this
			# reference needs to be set to null immediately.
			drag_ghost = null

		else:
			drag_node.global_position = drag_ghost.global_position

			drag_ghost.queue_free()
			drag_ghost = null

func _revert_drag_tween_finished() -> void:
	drag_ghost.queue_free()
	drag_ghost = null
