extends StaticBody2D

class_name Block

signal drag_start

var block_scene: PackedScene
var cell_size: Vector2 = Vector2(32, 32)

func _enter_tree() -> void:
	set_notify_transform(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		position = snapped(position, cell_size)

func _ready() -> void:
	input_pickable = true
	block_scene = load(scene_file_path) as PackedScene

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_mouse_pressed()

func _mouse_pressed() -> void:
	drag_start.emit(self)

func set_drag_and_drop_state(state: int) -> void:
	match state:
		DragAndDrop.STATE_GHOST:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0

		DragAndDrop.STATE_COLLISION:
			modulate.a = 0.4
			modulate.r = 1.0
			modulate.g = 0.2
			modulate.b = 0.2

		_:
			modulate.a = 1.0
			modulate.r = 1.0
			modulate.g = 1.0
			modulate.b = 1.0

func clone() -> Block:
	var clone: Block = block_scene.instantiate()
	clone.rotation = rotation
	return clone
