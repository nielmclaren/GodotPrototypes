extends Node

var held_object:Draggable = null

func register_draggable(draggable:Draggable) -> void:
	draggable.clicked.connect(_on_pickable_clicked)

func release() -> void:
	if held_object:
		held_object.drop(Input.get_last_mouse_velocity())
		held_object = null

func _on_pickable_clicked(object:Draggable) -> void:
	if !held_object:
		object.pickup()
		held_object = object
