extends Node2D

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event:InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT \
				and !mouse_event.pressed:
			DragManager.release()
