extends RigidBody2D

class_name Mirror

func _input_event(viewport:Viewport, event:InputEvent, shape_idx:int) -> void:
	($Draggable as Draggable).input_event(viewport, event, shape_idx)
