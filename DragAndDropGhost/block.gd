extends StaticBody2D

class_name Block

signal clicked

var block_scene: PackedScene

func _ready() -> void:
	input_pickable = true
	block_scene = load(scene_file_path) as PackedScene

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_mouse_pressed()

func _mouse_pressed() -> void:
	clicked.emit(self)

func clone() -> Block:
	var clone: Block = block_scene.instantiate()
	clone.rotation = rotation
	return clone
