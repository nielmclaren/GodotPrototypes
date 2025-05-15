class_name DragTranslation
extends Node

@export var body: Node2D
@export var translation_handle: Area2D
@export var rotation_handle: Area2D

var is_translation_mouse_over: bool = false
var is_rotation_mouse_over: bool = false
var is_translating: bool = false
var is_rotating: bool = false
var translation_click_offset: Vector2 = Vector2.ZERO
var rotation_click_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	translation_handle.input_pickable = true
	translation_handle.mouse_entered.connect(_translation_mouse_entered)
	translation_handle.mouse_exited.connect(_translation_mouse_exited)
	translation_handle.input_event.connect(_translation_input_event)

	rotation_handle.input_pickable = true
	rotation_handle.mouse_entered.connect(_rotation_mouse_entered)
	rotation_handle.mouse_exited.connect(_rotation_mouse_exited)
	rotation_handle.input_event.connect(_rotation_input_event)


func _physics_process(_delta: float) -> void:
	if !GlobalState.is_game_input_enabled:
		return

	if is_translating:
		body.global_position = body.get_global_mouse_position() - translation_click_offset

	if is_rotating:
		var to_mouse: Vector2 = body.get_global_mouse_position() - body.global_position
		body.rotation = rotate_toward(body.rotation, to_mouse.angle() - rotation_click_offset.angle(), 1)

	if is_translating:
		CursorManager.cursor_set_shape(Input.CURSOR_DRAG)
	elif is_rotating or is_rotation_mouse_over:
		CursorManager.cursor_set_shape(Input.CURSOR_CROSS)
	elif is_translation_mouse_over:
		# When rotating, moving the mouse over the translation handle should not change to drag cursor.
		CursorManager.cursor_set_shape(Input.CURSOR_DRAG)
	else:
		CursorManager.cursor_set_shape(Input.CURSOR_ARROW)


func _translation_mouse_entered() -> void:
	is_translation_mouse_over = true


func _translation_mouse_exited() -> void:
	is_translation_mouse_over = false


func _rotation_mouse_entered() -> void:
	is_rotation_mouse_over = true


func _rotation_mouse_exited() -> void:
	is_rotation_mouse_over = false


func _translation_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_translation_mouse_pressed()
			viewport.set_input_as_handled()


func _translation_mouse_pressed() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	is_translating = true
	translation_click_offset = body.get_global_mouse_position() - body.global_position


func _rotation_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_rotation_mouse_pressed()
			viewport.set_input_as_handled()


func _rotation_mouse_pressed() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	is_rotating = true
	rotation_click_offset = body.get_local_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and !mouse_event.pressed:
			_mouse_released()


func _mouse_released() -> void:
	if !GlobalState.is_game_input_enabled:
		return

	is_translating = false
	is_rotating = false
